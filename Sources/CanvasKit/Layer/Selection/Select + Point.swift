//
//  Select + Color.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import CoreGraphics
import MetalManager
import Metal
import Stratum


public struct SelectByColorFromPoint: SelectionCriteria {
    
    let index: Index
    
    let tolerance: UInt8
    
    
    public func select(layer: Layer) throws -> Mask {
        let mask = try SelectByColor(color: layer.color(at: index), tolerance: tolerance).select(layer: layer)
        
        let maskLength = (layer.width * layer.height)
        
        let maskBuffer = UnsafeMutableBufferPointer<Bool>.allocate(capacity: maskLength)
        maskBuffer.initialize(repeating: false)
        
        var queue = Queue<Index>()
        queue.enqueue(index)
        
        let isVisited = BoolMatrix(width: layer.width, height: layer.height, fill: false)
        
        while let next = queue.next() {
            if !isVisited[next] && mask[next]  {
                isVisited[next] = true
                maskBuffer[next.y &* layer.width &+ next.x] = true
                
                for adjacent in next.adjacent(width: layer.width, height: layer.height) {
                    if !isVisited[adjacent] && mask[adjacent] {
                        queue.enqueue(adjacent)
                    }
                }
            }
        }
        
        return Mask(BytesNoCopy: maskBuffer, width: layer.width, height: layer.height, deallocator: .free)
    }
    
}


extension SelectionCriteria where Self == SelectByColorFromPoint {
    
    public static func color(at index: CGPoint, tolerance: UInt8 = 20) -> SelectByColorFromPoint {
        SelectByColorFromPoint(index: Index(index), tolerance: tolerance)
    }
    
}
