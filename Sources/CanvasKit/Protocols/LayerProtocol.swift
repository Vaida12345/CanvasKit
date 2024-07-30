//
//  LayerProtocol.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import CoreGraphics


/// The protocol that all layers and Canvas conforms to.
public protocol LayerProtocol {
    
    /// Returns the context which could represent the layer.
    ///
    /// - Important: making the context involves rendering and/or converting buffer from the GPUs, hence is a heavy operation.
    func makeContext() async throws -> CGContext
    
}


public extension LayerProtocol {
    
    /// Render as a CGImage.
    func render() async throws -> CGImage {
        try await self.makeContext().makeImage()!
    }
    
}
