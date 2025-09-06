//
//  Layer + Initializers.swift
//
//
//  Created by Vaida on 7/5/24.
//

import Foundation
import CoreGraphics
@preconcurrency import SwiftUI
import MetalManager



extension Layer {
    
    /// Initialize the container with the image given.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(_ image: CGImage, origin: CGPoint = .zero, context: MetalContext) async throws {
        let device = CanvasKitConfiguration.computeDevice
        let texture = try await device.makeTexture(from: image, usage: .shaderReadWrite, context: context)
        
        self.init(texture: texture, origin: origin, colorSpace: image.colorSpace!, context: context)
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
    
    /// Initialize the container with the image given.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - center: The point relative to the canvas.
    public convenience init(_ image: CGImage, center: CGPoint, context: MetalContext) async throws {
        let width = image.width
        let height = image.height
        
        try await self.init(image, origin: CGRect(center: center, size: CGSize(width: width, height: height)).origin, context: context)
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
        descriptor.storageMode = .private
        
        let device = CanvasKitConfiguration.computeDevice
        let texture = device.makeTexture(descriptor: descriptor)!
        
        self.init(texture: texture, origin: origin, colorSpace: colorSpace, context: context)
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
    
    /// Initialize the container filled with the given color.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(fill: PartialColor, width: Int, height: Int, origin: CGPoint = .zero, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB(), context: MetalContext) async throws {
        self.init(width: width, height: height, origin: origin, colorSpace: colorSpace, context: context)
        
        guard fill != .white else { return }
        try await self.fill(fill, selection: Mask(repeating: 255, width: width, height: height, context: context))
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
    
    /// Initialize the container filled with the given color.
    ///
    /// The image will be converted into a 8 bits-per-component, with premultiplied last alpha.
    ///
    /// - Parameters:
    ///   - origin: The point relative to the canvas.
    public convenience init(fill: PartialColor, frame: CGRect, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB(), context: MetalContext) async throws {
        try await self.init(fill: fill, width: Int(frame.width), height: Int(frame.height), origin: frame.origin, colorSpace: colorSpace, context: context)
        
        self.texture.label = "Layer.Texture<(\(width), \(height), 4)>(origin: \(#function))"
    }
    
    @MainActor
    public convenience init(_ view: some View, size: CGSize, context: MetalContext) async throws {
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(size)
        try await self.init(renderer.cgImage!, context: context)
    }
    
}


extension Layer: Identifiable {
    
}

extension Layer: Equatable {
    
    public static func == (_ lhs: Layer, _ rhs: Layer) -> Bool {
        lhs.id == rhs.id
    }
    
}
