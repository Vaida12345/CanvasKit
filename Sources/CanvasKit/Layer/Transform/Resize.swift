//
//  Resize.swift
//  
//
//  Created by Vaida on 7/7/24.
//

import CoreGraphics


public struct ResizeTransformation: Transformation {
    
    let size: CGSize
    
    
    public func apply(layer: Layer) throws {
        let width = Int(size.width)
        let height = Int(size.height)
        
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: width * height * 4)
        let context = CGContext(data: buffer.baseAddress!, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: layer.colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        try context.draw(layer.render(), in: CGRect(origin: .zero, size: size))
        
        layer.set(
            buffer: buffer,
            width: width,
            height: height,
            origin: CGRect(center: layer.frame.center, size: size).origin,
            deallocator: .free
        )
    }
    
}


public extension Transformation where Self == ResizeTransformation {
    
    static func resize(to size: CGSize) -> ResizeTransformation {
        ResizeTransformation(size: size)
    }
    
}
