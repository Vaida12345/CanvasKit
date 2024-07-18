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
        let context = CGContext(data: nil, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: 4 * image.width, space: image.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(image, in: CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height)))
        self.init(
            buffer: CanvasKitConfiguration.computeDevice.makeBuffer(
                bytes: context.data!,
                length: image.width * image.height * 4 * MemoryLayout<UInt8>.stride,
                options: .storageModeShared
            )!,
            origin: origin,
            width: image.width,
            height: image.height,
            colorSpace: image.colorSpace!
        )
    }
    
    /// Initialize the container with the image given.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - center: The point relative to the canvas.
    public convenience init(_ image: CGImage, center: CGPoint) {
        let width = image.width
        let height = image.height
        
        self.init(image, origin: CGRect(center: center, size: CGSize(width: width, height: height)).origin)
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
    
    /// Initialize the container filled with clear
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(width: Int, height: Int, origin: CGPoint = .zero, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()) {
        let buffer = CanvasKitConfiguration.computeDevice.makeBuffer(
            length: width * height * 4 * MemoryLayout<UInt8>.stride,
            options: .storageModeShared
        )!
        
        self.init(buffer: buffer, origin: origin, width: width, height: height, colorSpace: colorSpace)
    }
    
    /// Initialize the container filled with the given color.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(fill: Color, frame: CGRect, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()) throws {
        let width = Int(frame.width)
        let height = Int(frame.height)
        
        let buffer = CanvasKitConfiguration.computeDevice.makeBuffer(
            length: width * height * 4 * MemoryLayout<UInt8>.stride,
            options: .storageModeShared
        )!
        buffer.label = "Layer.buffer<(\(width), \(height), 4)>(origin: \(#function))"
        
        self.init(buffer: buffer, frame: frame, colorSpace: colorSpace)
        let mask = try Mask(repeating: true, width: width, height: height)
        try self.fill(color: fill, selection: mask)
    }
    
    /// Initialize the container filled with clear
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(frame: CGRect, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()) {
        let width = Int(frame.width)
        let height = Int(frame.height)
        
        let buffer = CanvasKitConfiguration.computeDevice.makeBuffer(
            length: width * height * 4 * MemoryLayout<UInt8>.stride,
            options: .storageModeShared
        )!
        buffer.label = "Layer.buffer<(\(width), \(height), 4)>(origin: \(#function))"
        
        self.init(buffer: buffer, frame: frame, colorSpace: colorSpace)
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
