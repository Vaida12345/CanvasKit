//
//  Select + Color.swift
//  
//
//  Created by Vaida on 7/5/24.
//


import Metal
import MetalManager
import CoreGraphics
import Optimization


public struct SelectByColorFromPoint: SelectionCriteria {
    
    let index: Index
    
    let tolerance: Float
    
    let contiguous: Bool
    
    
    /// Selects pixels that match the color sampled at `index`.
    ///
    /// - Important: `index` must be inside the layer bounds.
    public func select(layer: Layer) async throws -> Mask {
        precondition(index.x < layer.width && index.y < layer.height)
        
        let texture = Mask.makeTexture(width: layer.width, height: layer.height)
        
        try await MetalFunction(name: "layer_selectByPoint", bundle: .module)
            .argument(texture: layer.texture)
            .argument(texture: texture)
            .argument(bytes: tolerance)
            .argument(bytes: SIMD2<UInt32>(UInt32(index.x), UInt32(index.y)))
            .dispatch(to: layer.context, width: layer.width, height: layer.height)
        
        let mask = Mask(texture: texture, context: layer.context)
        
        guard contiguous else { return mask }
        
        try await mask.context.synchronize()
        let originalMaskBuffer = try mask.texture.makeBuffer(channelsCount: 1)
        defer { originalMaskBuffer.deallocate() }
        let width = mask.width
        let height = mask.height
        
        let maskLength = width * height
        let maskBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: maskLength)
        maskBuffer.initialize(repeating: 0)
        defer { maskBuffer.deallocate() }
        
        let queue = RingBuffer<Index>()
        let isVisited = BoolMatrix(width: width, height: height, fill: false)
        
        isVisited[index] = true
        if originalMaskBuffer[index.flatten(width: width)] != 0 {
            queue.append(index)
        }
        
        while let next = queue.next() {
            let flattened = next.flatten(width: width)
            maskBuffer[flattened] = 255
            
            @inline(__always)
            func enqueueIfNeeded(_ candidate: Index?) {
                guard let candidate else { return }
                guard !isVisited[candidate] else { return }
                isVisited[candidate] = true
                guard originalMaskBuffer[candidate.flatten(width: width)] != 0 else { return }
                queue.append(candidate)
            }
            
            enqueueIfNeeded(next.move(down: 0, right: 1, width: width, height: height))
            enqueueIfNeeded(next.move(down: 1, right: 0, width: width, height: height))
            enqueueIfNeeded(next.move(down: 0, right: -1, width: width, height: height))
            enqueueIfNeeded(next.move(down: -1, right: 0, width: width, height: height))
        }
        
        let newMaskTexture = Mask.makeTexture(width: width, height: height)
        newMaskTexture.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: maskBuffer.baseAddress!, bytesPerRow: width)
        
        return Mask(texture: newMaskTexture, context: mask.context)
    }
    
}


public extension SelectionCriteria where Self == SelectByColorFromPoint {
    
    /// Select by the color at given point.
    ///
    /// - Complexity: This will synchronize the context when `contiguous`.
    static func color(at point: CGPoint, tolerance: Float = 0.1, contiguous: Bool = true) -> SelectByColorFromPoint {
        return SelectByColorFromPoint(index: Index(point), tolerance: tolerance, contiguous: contiguous)
    }
    
}
