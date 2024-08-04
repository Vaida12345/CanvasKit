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
    
    let tolerance: Float
    
    let contiguous: Bool
    
    
    public func select(layer: Layer) async throws -> Mask {
        let color = try await layer.color(at: index)
        let partialColor = PartialColor(red: Float(color[0]) / 255, green: Float(color[1]) / 255, blue: Float(color[2]) / 255, alpha: Float(color[3]) / 255)
        let mask = try await SelectByColor(color: partialColor, tolerance: tolerance).select(layer: layer)
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
    static func color(at point: CGPoint, tolerance: Float = 0.1, contiguous: Bool = true) -> SelectByColorFromPoint {
        SelectByColorFromPoint(index: Index(point), tolerance: tolerance, contiguous: contiguous)
    }
    
}
