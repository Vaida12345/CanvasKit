//
//  Layer.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Foundation
import CoreGraphics
import Metal
import MetalManager
import OSLog


/// An image layer, the direct container to an image buffer.
///
/// This container is tightly bound to the underlying texture. Its texture is allocated on creation, and cannot be changed. (However, the contents of such texture can). In this design, any functions that would involve creation of a new texture returns a new layer.
public final class Layer: LayerProtocol {
    
    public let texture: any MTLTexture
    
    /// The frame relative to the Canvas.
    ///
    /// - Invariant: the origin is relative to the canvas, which means this value may be modified when the parent canvas changes in size.
    ///
    /// - Invariant: this implementation does not use `CoreGraphics` for rendering, hence the origin was chosen to be top-left corner.
    public private(set) var origin: CGPoint
    
    let context: MetalContext
    
    let colorSpace: CGColorSpace
    
    /// The width of the texture.
    public var width: Int {
        self.texture.width // surprisingly, this is only. As the size of texture cannot be modified. This would always reflect the actual size of the size. And it's the same for `height`.
    }
    
    /// The height of the texture.
    public var height: Int {
        self.texture.height
    }
    
    public var size: CGSize {
        CGSize(width: self.texture.width, height: self.texture.height)
    }
    
    
    public func makeContext() async throws -> CGContext {
        let logger = Logger(subsystem: "CanvasKit", category: "Layer")
        let date = Date()
        try await self.context.synchronize()
        logger.info("Layer.makeContext, synchronize took \(date.distanceToNow())")
        let data = self.texture.makeBuffer(channelsCount: 4)
        
        return CGContext(data: data.baseAddress!, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    }
    
    public func move(to point: CGPoint) {
        self.origin = point
    }
    
    public init(texture: any MTLTexture, origin: CGPoint = .zero, colorSpace: CGColorSpace, context: MetalContext) {
        self.texture = texture
        self.origin = origin
        self.colorSpace = colorSpace
        self.context = context
    }
    
    public convenience init(texture: any MTLTexture, frame: CGRect, colorSpace: CGColorSpace, context: MetalContext) {
        self.init(texture: texture, origin: frame.origin, colorSpace: colorSpace, context: context)
    }
    
}
