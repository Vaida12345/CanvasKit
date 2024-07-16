//
//  Layer + Expand.swift
//  
//
//  Created by Vaida on 7/16/24.
//

import CoreGraphics
import MetalManager
import GraphicsKit
import Metal


extension Layer {
    
    public func expand(to rect: CGRect) throws {
        let manager = try MetalManager(name: "layer_expand", fileWithin: .module)
        
        manager.setConstant(self.width)
        manager.setConstant(self.height)
        manager.setConstant(Int(rect.origin.x))
        manager.setConstant(Int(rect.origin.y))
        manager.setConstant(Int(rect.width))
        manager.setConstant(Int(rect.height))
        
        try manager.setBuffer(self.buffer)
        let buffer = try manager.setEmptyBuffer(count: Int(rect.width) * Int(rect.height) * 4, type: UInt8.self)
        
        try manager.perform(gridSize: MTLSize(width: Int(rect.width), height: Int(rect.height), depth: 4))
        
        self.set(
            buffer: UnsafeMutableBufferPointer(start: buffer.contents().assumingMemoryBound(to: UInt8.self), count: Int(rect.width) * Int(rect.height) * 4),
            width: Int(rect.width),
            height: Int(rect.height),
            origin: self.origin + rect.origin,
            deallocator: .none
        )
    }
    
}
