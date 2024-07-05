//
//  Layer + Delete.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import MetalManager
import Metal


extension Layer {
    
    public func delete(selection: Mask) throws {
        let manager = try MetalManager(name: "layer_delete", fileWithin: .module)
        
        manager.setConstant(self.width)
        
        let buffer = try manager.setBuffer(self.buffer)
        try manager.setBuffer(selection.buffer)
        
        try manager.perform(gridSize: MTLSize(width: self.width, height: self.height, depth: 1))
        self.buffer = UnsafeMutableBufferPointer(start: buffer.contents().bindMemory(to: UInt8.self, capacity: self.width * self.height), count: self.width * self.height)
        self.deallocator = .none
    }
    
}
