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
    
    /// Initialize the container with the image given.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(_ image: CGImage, origin: CGPoint = .zero, context: MetalContext) throws {
        let device = CanvasKitConfiguration.computeDevice
        let texture = try device.makeTexture(from: image, usage: .shaderReadWrite)
        
        self.init(texture: texture, frame: CGRect(origin: origin, size: CGSize(width: image.width, height: image.height)), colorSpace: image.colorSpace!, context: context)
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
    
    /// Initialize the container with the image given.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - center: The point relative to the canvas.
    public convenience init(_ image: CGImage, center: CGPoint, context: MetalContext) throws {
        let width = image.width
        let height = image.height
        
        try self.init(image, origin: CGRect(center: center, size: CGSize(width: width, height: height)).origin, context: context)
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
    
    /// Initialize the container filled with clear
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(width: Int, height: Int, origin: CGPoint = .zero, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB(), context: MetalContext) {
        let descriptor = MTLTextureDescriptor()
        descriptor.height = height
        descriptor.width = width
        descriptor.pixelFormat = .rgba8Unorm
        descriptor.usage = .shaderReadWrite
        descriptor.storageMode = .shared
        
        let device = CanvasKitConfiguration.computeDevice
        let texture = device.makeTexture(descriptor: descriptor)!
        
        self.init(texture: texture, frame: CGRect(origin: origin, size: CGSize(width: width, height: height)), colorSpace: colorSpace, context: context)
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
    
    /// Initialize the container filled with clear
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(frame: CGRect, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB(), context: MetalContext) {
        self.init(width: Int(frame.width), height: Int(frame.height), origin: frame.origin, colorSpace: colorSpace, context: context)
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
    
#if false
    /// Initialize the container filled with the given color.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(fill: Color, width: Int, height: Int, origin: CGPoint = .zero, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB(), context: MetalContext) throws {
        self.init(width: width, height: height, origin: origin, colorSpace: colorSpace, context: context)
        
        guard fill != .white else { return }
        try self.fill(color: fill, selection: Mask(repeating: 1, width: width, height: height, context: context))
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
    
    /// Initialize the container filled with the given color.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(fill: Color, frame: CGRect, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB(), context: MetalContext) throws {
        try self.init(fill: fill, width: Int(frame.width), height: Int(frame.height), colorSpace: colorSpace, context: context)
        
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
#endif
    
    @MainActor
    public convenience init(_ view: some View, size: CGSize, context: MetalContext) throws {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(size)
        try self.init(renderer.cgImage!, context: context)
    }
    
}


extension Layer: Identifiable {
    
}

extension Layer: Equatable {
    
    public static func == (_ lhs: Layer, _ rhs: Layer) -> Bool {
        lhs.id == rhs.id
    }
    
}
