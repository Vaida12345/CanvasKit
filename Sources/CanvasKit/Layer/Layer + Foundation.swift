//
//  Layer + Foundation.swift
//  CanvasKit
//
//  Created by Vaida on 7/31/24.
//

import Foundation
import MetalManager


public extension Layer {
    
    /// Copy the layer.
    ///
    /// Performs a bit-wise copying, so that the new layer is detached from the original one.
    func copy() async throws -> Layer {
        let newLayer = Layer(width: self.width, height: self.height, origin: self.origin, colorSpace: self.colorSpace, context: self.context)
        newLayer.texture.label = "Layer.Texture<(\(width), \(height), 4)>(copiedFrom: \(self.texture.label ?? "(unknown)"))"
        
        try await MetalFunction(name: "layer_duplicate", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newLayer.texture)
            .dispatch(to: self.context.addJob(), width: self.width, height: self.height)
        
        return newLayer
    }
    
    /// Copy the layer.
    ///
    /// Performs a bit-wise copying, so that the new layer is detached from the original one.
    ///
    /// - Parameters:
    ///   - selection: If provided, only the selected region will be copied.
    func copy(selection: Mask) async throws -> Layer {
        precondition(selection.size == self.size, "Attempting to apply a mask to an layer of different size. Tip: You can use `Mask.expanding(to:)` to expand or shrink the mask.")
        
        let newLayer = Layer(width: self.width, height: self.height, origin: self.origin, colorSpace: self.colorSpace, context: self.context)
        newLayer.texture.label = "Layer.Texture<(\(width), \(height), 4)>(copiedFrom: \(self.texture.label ?? "(unknown)"), with: \(selection.texture.label ?? "(unknown)"))"
        
        try await MetalFunction(name: "layer_duplicate_with_mask", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newLayer.texture)
            .argument(texture: selection.texture)
            .dispatch(to: self.context.addJob(), width: self.width, height: self.height)
        
        return newLayer
    }
    
    /// Determines if two layers are equal.
    ///
    /// - Complexity: This would involve using CPU to determine, hence both `self` and `rhs` would be synced.
    func isBitwiseEqual(to rhs: Layer) async throws -> Bool {
        try await self.context.synchronize()
        try await rhs.context.synchronize()
        
        guard self.texture.width == rhs.texture.width,
              self.texture.height == rhs.texture.height,
              self.texture.pixelFormat == rhs.texture.pixelFormat,
              self.texture.mipmapLevelCount == rhs.texture.mipmapLevelCount,
              self.texture.arrayLength == rhs.texture.arrayLength else {
            return false
        }
        
        let _lhs = self.texture.makeBuffer(channelsCount: 4)
        let _rhs = rhs.texture.makeBuffer(channelsCount: 4)
        
        defer {
            _lhs.deallocate()
            _rhs.deallocate()
        }
        
        return memcmp(_lhs.baseAddress, _rhs.baseAddress, _rhs.count) == 0
    }
    
    
    /// Fill the area masked by `mask` by the `color`.
    ///
    /// If a channel is `nil`, that channel is unmodified.
    func fill(_ color: PartialColor, mask: Mask) async throws {
        try await MetalFunction(name: "layer_fill", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: mask.texture)
            .argument(bytes: color)
            .dispatch(to: self.context.addJob(), width: self.width, height: self.height)
    }
    
}
