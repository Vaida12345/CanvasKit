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


/// An image layer, the direct container to an image buffer.
public final class Layer: LayerProtocol {
    
    internal private(set) var texture: any MTLTexture
    
    /// The frame relative to the Canvas.
    ///
    /// - Invariant: the origin is relative to the canvas, which means this value may be modified when the parent canvas changes in size.
    ///
    /// - Invariant: this implementation does not use `CoreGraphics` for rendering, hence the origin was chosen to be top-left corner.
    public private(set) var origin: CGPoint
    
    let context: MetalContext
    
    let colorSpace: CGColorSpace
    
    
    public var width: Int {
        self.texture.width
    }
    
    public var height: Int {
        self.texture.height
    }
    
    public var size: CGSize {
        CGSize(width: self.texture.width, height: self.texture.height)
    }
    
    
    public func makeContext() async throws -> CGContext {
        try await self.context.synchronize()
        let data = self.texture.makeBuffer()
        
        return CGContext(data: data.baseAddress!, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    }
    
    func set(texture: any MTLTexture, origin: CGPoint) {
        self.texture = texture
        self.origin = origin
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
