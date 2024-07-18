//
//  Shift.swift
//  
//
//  Created by Vaida on 7/18/24.
//

import CoreGraphics
import MetalManager


public struct ShiftTransformation: Transformation {
    
    let offset_x: Int
    let offset_y: Int
    
    
    public func apply(layer: Layer) throws {
        let manager = try MetalManager(name: "transform_shift", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        
        manager.setConstant(layer.width)
        manager.setConstant(layer.height)
        manager.setConstant(offset_x)
        manager.setConstant(offset_y)
        
        try manager.setBuffer(layer.buffer)
        let result = try manager.setEmptyBuffer(count: 4 * layer.width * layer.height, type: UInt8.self)
        result.label = "Layer.buffer<(\(layer.width), \(layer.height), 4)>(origin: ShiftTransformation.apply(layer:))"
        
        try manager.perform(width: layer.width, height: layer.height, depth: 4)
        
        layer.set(buffer: result, frame: layer.frame)
    }
    
}


public extension Transformation where Self == ShiftTransformation {
    
    static func shift(x: Int, y: Int) -> ShiftTransformation {
        ShiftTransformation(offset_x: x, offset_y: y)
    }
    
    static func shift(_ offset: CGPoint) -> ShiftTransformation {
        ShiftTransformation(offset_x: Int(offset.x), offset_y: Int(offset.y))
    }
    
}
