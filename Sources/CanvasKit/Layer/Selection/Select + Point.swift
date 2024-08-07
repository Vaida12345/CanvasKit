//
//  Select + Color.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Stratum
import Metal
import MetalManager
import CoreGraphics


public struct SelectByColorFromPoint: SelectionCriteria {
    
    let index: Index
    
    let tolerance: Float16
    
    let contiguous: Bool
    
    
    public func select(layer: Layer) async throws -> Mask {
        precondition(index.x <= layer.width && index.y <= layer.height)
        
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
        let width = mask.width
        
        let maskLength = (layer.width * layer.height)
        let maskBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: maskLength)
        maskBuffer.initialize(repeating: 0)
        
        var queue = Queue<Index>()
        queue.enqueue(index)
        
        let isVisited = BoolMatrix(width: layer.width, height: layer.height, fill: false)
        
        while let next = queue.next() {
            if !isVisited[next] && originalMaskBuffer[next.flatten(width: width)] != 0 {
                isVisited[next] = true
                maskBuffer[next.flatten(width: width)] = 255
                
                for adjacent in next.adjacent(width: layer.width, height: layer.height) {
                    if !isVisited[adjacent] && originalMaskBuffer[adjacent.flatten(width: width)] != 0 {
                        queue.enqueue(adjacent)
                    }
                }
            }
        }
        
        let newMaskTexture = Mask.makeTexture(width: mask.width, height: mask.height)
        newMaskTexture.replace(region: MTLRegionMake2D(0, 0, mask.width, mask.height), mipmapLevel: 0, withBytes: maskBuffer.baseAddress!, bytesPerRow: mask.width)
        maskBuffer.deallocate()
        
        return Mask(texture: newMaskTexture, context: mask.context)
    }
    
}


public extension SelectionCriteria where Self == SelectByColorFromPoint {
    
    /// Select by the color at given point.
    ///
    /// - Complexity: This will synchronize the context when `contiguous`.
    static func color(at point: CGPoint, tolerance: Float16 = 0.1, contiguous: Bool = true) -> SelectByColorFromPoint {
        return SelectByColorFromPoint(index: Index(point), tolerance: tolerance, contiguous: contiguous)
    }
    
}
