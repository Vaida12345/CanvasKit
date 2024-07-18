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
    
    /// Expand the Layer.
    ///
    /// The current layer would be drawn on the new layer using this computation:
    /// ```swift
    /// newPixel.position = oldPixel.position - rect.origin
    /// ```
    ///
    /// This is intuitive, for example
    ///
    /// If you would like it to stay at the center of the canvas, use 
    ///
    /// ``` swift
    /// CGRect(center: self.frame.center, size: size)
    /// ```
    ///
    /// - If `size > frame.size`, the origin is a negative number, the new pixels are mapped to a higher index.
    /// - If `size < frame.size`, the origin is a positive number, the new pixels are mapped to a lower index.
    ///
    /// To explicitly state the origin on the *new* canvas, use
    ///
    /// ```swift
    /// CGRect(origin: -origin_on_new_canvas, size: size)
    /// ```
    public func expand(to rect: CGRect) throws {
        let manager = try MetalManager(name: "layer_expand", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        
        manager.setConstant(self.width)
        manager.setConstant(self.height)
        manager.setConstant(Int(rect.origin.x))
        manager.setConstant(Int(rect.origin.y))
        manager.setConstant(Int(rect.width))
        manager.setConstant(Int(rect.height))
        
        try manager.setBuffer(self.buffer)
        let buffer = try manager.setEmptyBuffer(count: Int(rect.width) * Int(rect.height) * 4, type: UInt8.self)
        
        try manager.perform(gridSize: MTLSize(width: self.width, height: self.height, depth: 4))
        
        self.set(
            buffer: buffer,
            width: Int(rect.width),
            height: Int(rect.height),
            origin: self.origin + rect.origin
        )
    }
    
}
