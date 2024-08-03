//
//  LayerProtocol.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Metal
import MetalManager
import CoreGraphics


/// The protocol that all layers and Canvas conforms to.
public protocol LayerProtocol {
    
    /// The underlying texture.
    ///
    /// Please note that this texture could be un-synced, to get a synchronized texture for your CPU, which is rare, you can call ``makeTexture()``.
    var texture: any MTLTexture { get }
    
    /// The context in which operations on the layer would run.
    var context: MetalContext { get }
    
    /// Returns the underlying texture.
    ///
    /// - Important: This will synchronize the context. If you do not want to synchronize, use
    func makeTexture() async throws -> any MTLTexture
    
    /// Renders the layer as CGImage.
    ///
    /// - Important: This will synchronize the context.
    func render() async throws -> CGImage
    
}


extension LayerProtocol {
    
    public func makeTexture() async throws -> any MTLTexture {
        try await self.context.synchronize()
        return self.texture
    }
    
}
