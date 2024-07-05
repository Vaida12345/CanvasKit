//
//  Layer + CoreGraphics.swift
//  
//
//  Created by Vaida on 7/5/24.
//


import CoreGraphics
import MetalManager
import Metal


extension Layer {
    
    public func crop(to rect: CGRect) throws {
        let manager = try MetalManager(name: "layer_crop", fileWithin: .module)
        
        manager.setConstant(self.width)
        manager.setConstant(UInt(rect.origin.x))
        manager.setConstant(UInt(rect.origin.y))
        manager.setConstant(UInt(rect.width))
        manager.setConstant(UInt(rect.height))
        
        try manager.setBuffer(self.buffer)
        let buffer = try manager.setEmptyBuffer(count: Int(rect.width) * Int(rect.height) * 4, type: UInt8.self)
        
        try manager.perform(gridSize: MTLSize(width: Int(rect.width), height: Int(rect.height), depth: 4))
        
        self.set(
            buffer: UnsafeMutableBufferPointer(start: buffer.contents().assumingMemoryBound(to: UInt8.self), count: Int(rect.width) * Int(rect.height) * 4),
            width: Int(rect.width),
            height: Int(rect.height),
            origin: self.origin,
            deallocator: .none
        )
//        print(Array(self.buffer))
//        print(self.buffer.count, self.width, self.height)
        
#warning("What about origin?")
    }
    
}
