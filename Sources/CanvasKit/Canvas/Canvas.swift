//
//  Canvas.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import CoreGraphics


/// A canvas, made up of images.
public final class Canvas: LayerProtocol {
    
    /// The newer layers are on top.
    public var layers: [Layer]
    
    public var size: CGSize
    
    
    public func makeContext() throws -> CGContext {
        let context = CGContext(data: nil, width: Int(size.width), height: Int(size.width), bitsPerComponent: 8, bytesPerRow: 4 * Int(size.width), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        for layer in layers {
            try context.draw(layer.render(), in: layer.frame)
        }
        return context
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
