//
//  Resize.swift
//  
//
//  Created by Vaida on 7/7/24.
//

import CoreGraphics
import MetalManager


public struct ResizeTransformation: Transformation {
    
    let size: CGSize
    
    
    public func apply(layer: Layer) throws {
        let manager = try MetalManager(name: "lanczosResample", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        
        manager.setConstant(2)
        manager.setConstant(Int(layer.size.width))
        manager.setConstant(Int(layer.size.height))
        manager.setConstant(Int(size.width))
        manager.setConstant(Int(size.height))
        
        try manager.setBuffer(layer.buffer)
        let result = try manager.setEmptyBuffer(count: 4 * Int(size.width) * Int(size.height), type: UInt8.self)
        
        try manager.perform(width: Int(size.width), height: Int(size.height))
        
        layer.set(buffer: result, frame: CGRect(center: layer.frame.center, size: size))
    }
    
}


public extension Transformation where Self == ResizeTransformation {
    
    static func resize(to size: CGSize) -> ResizeTransformation {
        ResizeTransformation(size: size)
    }
    
}
