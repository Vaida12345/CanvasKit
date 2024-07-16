//
//  Subtract.swift
//  
//
//  Created by Vaida on 6/28/24.
//

import Metal
import MetalManager


public struct SubtractOperation: LayerOperations {
    
    let rhs: Layer
    
    
    public func apply(layer: Layer) throws {
        precondition(layer.width == rhs.width && layer.height == rhs.height)
        let manager = try MetalManager(name: "subtract", fileWithin: .module)
        
        manager.setConstant(layer.width)
        
        try manager.setBuffer(layer.buffer)
        try manager.setBuffer(rhs.buffer)
        
        try manager.perform(gridSize: MTLSize(width: layer.width, height: layer.height, depth: 3))
        
        layer.set(buffer: layer.buffer, frame: layer.frame)
    }
    
}


extension LayerOperations where Self == SubtractOperation {
    
    public static func subtract(_ rhs: Layer) -> SubtractOperation {
        SubtractOperation(rhs: rhs)
    }
    
}
