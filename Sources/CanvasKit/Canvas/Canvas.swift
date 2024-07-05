//
//  Canvas.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import CoreGraphics


/// A canvas, made up of images.
public final class Canvas: LayerProtocol {
    
    var layers: [Layer]
    
    var width: Int
    
    var height: Int
    
    
    public func makeContext() -> CGContext {
        let context = CGContext(data: nil, width: self.width, height: self.height, bitsPerComponent: 8, bytesPerRow: 4 * self.width, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        for layer in layers {
            context.draw(layer.render(), in: CGRect(origin: layer.origin, size: CGSize(width: layer.width, height: layer.height)))
        }
        return context
    }
    
    
    init(layers: [Layer] = [], width: Int, height: Int) {
        self.layers = layers
        self.width = width
        self.height = height
    }
    
}
