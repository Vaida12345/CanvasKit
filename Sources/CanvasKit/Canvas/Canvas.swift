//
//  Canvas.swift
//  
//
//  Created by Vaida on 7/5/24.
//

#if false
import CoreGraphics
import MetalManager
import Metal
import GraphicsKit


/// A canvas, made up of images.
public final class Canvas: LayerProtocol {
    
    /// The newer layers are on top.
    public var layers: [Layer]
    
    public var size: CGSize
    
    public func makeBuffer() throws -> any MTLBuffer {
        if layers.count == 1,
           let layer = layers.first {
            let copy = layer.copy()
            try copy.expand(to: CGRect(origin: -copy.origin, size: self.size))
            return copy.buffer
        }
        
        let device = CanvasKitConfiguration.computeDevice
        guard let buffer = device.makeBuffer(length: Int(size.width) * Int(size.height) * 6 * MemoryLayout<UInt8>.size, options: .storageModeShared) else { throw MetalManager.Error.cannotCreateMetalCommandBuffer }
        
        for layer in layers {
            let manager = try MetalManager(name: "canvas_blend", fileWithin: .module, device: device)
            
            manager.setConstant(Int(size.width))
            manager.setConstant(Int(layer.width))
            manager.setConstant(Int(layer.height))
            manager.setConstant(Int(layer.origin.x))
            manager.setConstant(Int(layer.origin.y))
            
            try manager.setBuffer(buffer)
            try manager.setBuffer(layer.buffer)
            
            try manager.perform(width: Int(size.width), height: Int(size.height), depth: 3)
        }
        
        let manager = try MetalManager(name: "canvas_finalize", fileWithin: .module, device: device)
        
        manager.setConstant(Int(size.width))
        
        try manager.setBuffer(buffer)
        let result = try manager.setEmptyBuffer(count: Int(size.width) * Int(size.height) * 4, type: UInt8.self)
        result.label = "Canvas.Buffer<\(Int(size.width)), \(Int(size.height)), 4>(origin: Canvas.makeBuffer)"
        
        print("canvas finalize")
        try manager.perform(width: Int(size.width), height: Int(size.height))
        print("canvas finalize: done")
        
        return result
    }
    
    public func makeContext() throws -> CGContext {
        let buffer = try self.makeBuffer()
        
        return CGContext(
            data: buffer.contents(),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * Int(size.width),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
    }
    
    public func add(layer: Layer, at index: Int? = nil, transformations: Transformation...) throws {
        for transformation in transformations {
            try layer.transform(transformation)
        }
        
        self.add(layer: layer, at: index)
    }
    
    public func add(layer: Layer, at index: Int? = nil) {
        if let index {
            self.layers.insert(layer, at: index)
        } else {
            self.layers.append(layer)
        }
    }
    
    
    public init(layers: [Layer] = [], size: CGSize) {
        self.layers = layers
        self.size = size
    }
    
    public init(layers: [Layer] = [], width: Int, height: Int) {
        self.layers = layers
        self.size = CGSize(width: width, height: height)
    }
    
    public convenience init(layer: Layer) {
        self.init(layers: [layer], size: layer.frame.size)
    }
    
}
#endif
