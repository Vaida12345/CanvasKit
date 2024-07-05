//
//  Layer + Foundation.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Foundation
import CoreGraphics


extension Layer {
    
    /// Initialize the container with the image given.
    ///
    /// The image will be converted into a 8bits-per-component, with premultiplied last alpha.
    public convenience init(_ image: CGImage, origin: CGPoint) {
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: image.width * image.height * 4)
        
        let context = CGContext(data: buffer.baseAddress!, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: 4 * image.width, space: image.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(image, in: CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height)))
        self.init(byteNoCopy: buffer, origin: origin, width: image.width, height: image.height, colorSpace: image.colorSpace!, deallocator: .free)
    }
    
}
