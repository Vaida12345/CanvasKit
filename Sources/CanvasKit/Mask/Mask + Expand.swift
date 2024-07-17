//
//  Mask + Expand.swift
//  
//
//  Created by Vaida on 7/17/24.
//

import CoreGraphics
import MetalManager
import GraphicsKit
import Metal


extension Mask {
    
    public func expanding(to rect: CGRect) throws -> Mask {
        let manager = try MetalManager(name: "mask_expand", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        
        manager.setConstant(self.width)
        manager.setConstant(self.height)
        manager.setConstant(Int(rect.origin.x))
        manager.setConstant(Int(rect.origin.y))
        manager.setConstant(Int(rect.width))
        manager.setConstant(Int(rect.height))
        
        try manager.setBuffer(self.buffer)
        let buffer = try manager.setEmptyBuffer(count: Int(rect.width) * Int(rect.height), type: UInt8.self)
        buffer.label = "Mask.buffer<(\(Int(rect.width)), \(Int(rect.height)))>(origin: \(#function))"
        
        try manager.perform(gridSize: MTLSize(width: self.width, height: self.height, depth: 1))
        
        return Mask(buffer: buffer, size: rect.size)
    }
    
}
