//
//  Layer + Foundation.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Foundation
import CoreGraphics
import SwiftUI


extension Layer {
    
    public func move(to point: CGPoint) {
        self.origin = point
    }
    
    /// Initialize the container with the image given.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(_ image: CGImage, origin: CGPoint = .zero) {
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: image.width * image.height * 4)
        
        let context = CGContext(data: buffer.baseAddress!, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: 4 * image.width, space: image.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(image, in: CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height)))
        self.init(
            buffer: CanvasKitConfiguration.computeDevice.makeBuffer(
                bytes: buffer.baseAddress!,
                length: buffer.count * MemoryLayout<UInt8>.stride,
                options: .storageModeShared
            )!,
            origin: origin,
            width: image.width,
            height: image.height,
            colorSpace: image.colorSpace!
        )
        buffer.deallocate()
    }
    
    /// Initialize the container filled with the given color.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(fill: Color, width: Int, height: Int, origin: CGPoint = .zero, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()) throws {
        let buffer = CanvasKitConfiguration.computeDevice.makeBuffer(
            length: width * height * 4 * MemoryLayout<UInt8>.stride,
            options: .storageModeShared
        )!
        
        self.init(buffer: buffer, origin: origin, width: width, height: height, colorSpace: colorSpace)
        try self.fill(color: fill, selection: Mask(repeating: true, width: width, height: height))
    }
    
    @MainActor
    public convenience init(_ view: some View, size: CGSize) {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(size)
        self.init(renderer.cgImage!)
    }
    
}


extension Layer: Identifiable {
    
}

extension Layer: Equatable {
    
    public static func == (_ lhs: Layer, _ rhs: Layer) -> Bool {
        lhs.id == rhs.id
    }
    
}
