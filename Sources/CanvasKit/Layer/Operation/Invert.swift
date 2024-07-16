//
//  Invert.swift
//  Raw Graphics
//
//  Created by Vaida on 2023/10/11.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import Metal
import MetalManager


public struct InvertOperation: LayerOperations {
    
    public func apply(layer: Layer) throws {
        let manager = try MetalManager(name: "invert", fileWithin: .module)
        
        manager.setConstant(layer.width)
        
        try manager.setBuffer(layer.buffer)
        
        try manager.perform(gridSize: MTLSize(width: layer.width, height: layer.height, depth: 3))
        
        layer.set(buffer: layer.buffer, frame: layer.frame)
    }
    
}


extension LayerOperations where Self == InvertOperation {
    
    public static var invert: InvertOperation {
        InvertOperation()
    }
    
}
