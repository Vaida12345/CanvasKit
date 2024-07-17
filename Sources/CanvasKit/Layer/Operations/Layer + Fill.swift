//
//  Layer + Delete.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import MetalManager
import Metal


extension Layer {
    
    /// Fills selection with the given color.
    ///
    /// If a channel is `nil`, that channel is unmodified.
    public func fill(red: UInt8?, green: UInt8?, blue: UInt8?, alpha: UInt8?, selection: Mask) throws {
        precondition(selection.width == self.width && selection.height == self.height)
        let manager = try MetalManager(name: "layer_fill", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        
        manager.setConstant(self.width)
        manager.setConstant(red != nil)
        manager.setConstant(red ?? 0)
        manager.setConstant(green != nil)
        manager.setConstant(green ?? 0)
        manager.setConstant(blue != nil)
        manager.setConstant(blue ?? 0)
        manager.setConstant(alpha != nil)
        manager.setConstant(alpha ?? 0)
        
        self.buffer.label = "Layer.buffer<(\(self.width), \(self.height), 4)>"
        selection.buffer.label = "Selection.buffer<(\(selection.width), \(selection.height))>"
        
        try manager.setBuffer(self.buffer)
        assert(self.buffer.length == self.width * self.height * 4)
        try manager.setBuffer(selection.buffer)
        
        try manager.perform(gridSize: MTLSize(width: self.width, height: self.height, depth: 1))
        
        self.set(
            buffer: self.buffer,
            frame: self.frame
        )
    }
    
    /// Fills selection with the given color.
    public func fill(color: Color, selection: Mask) throws {
        try self.fill(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha, selection: selection)
    }
    
    public func delete(selection: Mask) throws {
        try self.fill(red: nil, green: nil, blue: nil, alpha: 0, selection: selection)
    }
    
}
