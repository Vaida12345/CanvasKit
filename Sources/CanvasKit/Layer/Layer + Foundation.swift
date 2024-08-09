//
//  Layer + Foundation.swift
//  CanvasKit
//
//  Created by Vaida on 7/31/24.
//

import Foundation
import MetalManager
import Stratum
import SwiftUI


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
            .dispatch(to: self.context, width: self.width, height: self.height)
        
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
            .dispatch(to: self.context, width: self.width, height: self.height)
        
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
        
        let _lhs = try self.texture.makeBuffer(channelsCount: 4)
        let _rhs = try rhs.texture.makeBuffer(channelsCount: 4)
        
        defer {
            _lhs.deallocate()
            _rhs.deallocate()
        }
        
        return memcmp(_lhs.baseAddress, _rhs.baseAddress, _rhs.count) == 0
    }
    
    
    /// Fill the area masked by `mask` by the `color`.
    ///
    /// If a channel is `nil`, that channel is unmodified.
    func fill(_ color: PartialColor, selection: Mask) async throws {
        precondition(selection.size == self.size, "Attempting to apply a mask to an layer of different size. Tip: You can use `Mask.expanding(to:)` to expand or shrink the mask.")
        
        try await MetalFunction(name: "layer_fill_with_mask", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: selection.texture)
            .argument(bytes: color)
            .dispatch(to: self.context, width: self.width, height: self.height)
    }
    
    /// Fill the area masked by `mask` by the `color`.
    ///
    /// If a channel is `nil`, that channel is unmodified.
    ///
    /// - Parameters:
    ///   - color: The filled color
    ///   - rect: The rect will be quantized to the nearest integer.
    func fill(_ color: PartialColor, selection rect: CGRect) async throws {
        let width = Int(rect.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(rect.height.rounded(.toNearestOrAwayFromZero))
        
        let origin = SIMD2<UInt32>(UInt32(rect.origin.x.rounded(.toNearestOrAwayFromZero)), UInt32(rect.origin.y.rounded(.toNearestOrAwayFromZero)))
        print("__marker__", origin)
        
        try await MetalFunction(name: "layer_fill_with_rect", bundle: .module)
            .argument(texture: self.texture)
            .argument(bytes: origin)
            .argument(bytes: color)
            .dispatch(to: self.context, width: width, height: height)
    }
    
    /// Fill the area masked by `mask` by the `color`.
    ///
    /// If a channel is `nil`, that channel is unmodified.
    func fill(_ color: PartialColor) async throws {
        try await MetalFunction(name: "layer_fill", bundle: .module)
            .argument(texture: self.texture)
            .argument(bytes: color)
            .dispatch(to: self.context, width: self.width, height: self.height)
    }
    
    /// Fill the area masked by `mask` by the `color`.
    ///
    /// If a channel is `nil`, that channel is unmodified.
    func fill(red: Float?, green: Float?, blue: Float?, alpha: Float?, selection: Mask? = nil) async throws {
        let color = PartialColor(red: red, green: green, blue: blue, alpha: alpha)
        
        if let selection {
            try await self.fill(color, selection: selection)
        } else {
            try await self.fill(color)
        }
    }
    
    /// Expand the Layer.
    ///
    /// The `origin` is the point relative to the original `(0, 0)`.
    ///
    /// The current layer would be drawn on the new layer using this computation:
    /// ```swift
    /// newPixel.position = oldPixel.position - rect.origin
    /// ```
    ///
    /// This is intuitive, for example
    ///
    /// If you would like it to stay at the center of the canvas, use
    ///
    /// ``` swift
    /// CGRect(center: self.frame.center, size: size)
    /// ```
    ///
    /// - If `size > frame.size`, the origin is a negative number, the new pixels are mapped to a higher index.
    /// - If `size < frame.size`, the origin is a positive number, the new pixels are mapped to a lower index.
    ///
    /// To explicitly state the origin on the *new* canvas, use
    ///
    /// ```swift
    /// CGRect(origin: -origin_on_new_canvas, size: size)
    /// ```
    func expanding(to rect: CGRect) async throws -> Layer {
        let width = Int(rect.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(rect.height.rounded(.toNearestOrAwayFromZero))
        
        let newLayer = Layer(width: width, height: height, origin: origin + rect.origin, colorSpace: colorSpace, context: context)
        newLayer.texture.label = "Layer.Texture<(\(width), \(height))>(expandOf: \(self.texture.label ?? "(unknown)"), by: \(rect))"
        
        try await MetalFunction(name: "layer_expand", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newLayer.texture)
            .argument(bytes: SIMD2<Float>(Float(rect.origin.x), Float(rect.origin.y)))
            .dispatch(to: self.context, width: width, height: height)
        
        return newLayer
    }
    
    /// Crop the Layer.
    ///
    /// - Note: This does exactly the same as ``expanding(to:)``
    ///
    /// The `origin` is the point relative to the original `(0, 0)`.
    ///
    /// The current layer would be drawn on the new layer using this computation:
    /// ```swift
    /// newPixel.position = oldPixel.position - rect.origin
    /// ```
    ///
    /// This is intuitive, for example
    ///
    /// If you would like it to stay at the center of the canvas, use
    ///
    /// ``` swift
    /// CGRect(center: self.frame.center, size: size)
    /// ```
    ///
    /// - If `size > frame.size`, the origin is a negative number, the new pixels are mapped to a higher index.
    /// - If `size < frame.size`, the origin is a positive number, the new pixels are mapped to a lower index.
    ///
    /// To explicitly state the origin on the *new* canvas, use
    ///
    /// ```swift
    /// CGRect(origin: -origin_on_new_canvas, size: size)
    /// ```
    func cropping(to rect: CGRect) async throws -> Layer {
        try await self.expanding(to: rect)
    }
    
    /// Invert the layer.
    func invert() async throws {
        try await MetalFunction(name: "layer_invert", bundle: .module)
            .argument(texture: self.texture)
            .dispatch(to: self.context, width: self.width, height: self.height)
    }
    
    /// Component-wise subtraction.
    ///
    /// This operation does not take the alpha channel into account, only if it is 0 or not. This would perform,
    ///
    /// ```c
    /// if (value[3] != 0) {
    ///     for (int i = 0; i < 3; i++) {
    ///         target[i] = target[i] - value[i];
    ///     }
    /// }
    /// ```
    ///
    /// - Tip: Due to the nature of such algorithm, subtracting an empty layer is the same as subtracting a black layer.
    ///
    /// - Warning: This will not take the origin into account.
    func subtract(_ other: Layer) async throws {
        precondition(self.size == other.size, "The two layers need to be of equal size to enable subtraction.")
        
        try await MetalFunction(name: "layer_subtract", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: other.texture)
            .dispatch(to: self.context, width: self.width, height: self.height)
    }
    
    /// Component-wise subtraction.
    ///
    /// To read more, see ``subtract(_:)``.
    static func -= (_ lhs: Layer, _ rhs: Layer) async throws {
        try await lhs.subtract(rhs)
    }
    
    /// Returns a layer by applying the `kernel` to the image matrix using reflective padding.
    ///
    /// - Note: By returning a new layer, the current layer is unmodified.
    ///
    /// For example, to apply Gaussian blur, use the kernel of
    ///
    /// ```swift
    /// .convolution(
    ///     kernel: Matrix([
    ///         [1/273,  4/273,  7/273,  4/273,  1/273],
    ///         [4/273, 16/273, 26/273, 16/273,  4/273],
    ///         [7/273, 26/273, 41/273, 26/273,  7/273],
    ///         [4/273, 16/273, 26/273, 16/273,  4/273],
    ///         [1/273,  4/273,  7/273,  4/273,  1/273],
    ///     ] as [[Float]])
    /// )
    /// ```
    ///
    /// The sum of the matrix is one, which would indicate the image received no gain.
    func convolution(kernel: Matrix<Float>, components: Components = .all) async throws -> Layer {
        let newLayer = Layer(width: self.width, height: self.height, origin: self.origin, colorSpace: self.colorSpace, context: self.context)
        newLayer.texture.label = "Layer.Texture<(\(width), \(height), 4)>(convOf: \(self.texture.label ?? "(unknown)"))"
        
        let _kernel = try MetalManager.computeDevice.makeBuffer(bytes: UnsafeMutableBufferPointer(start: kernel.pointer, count: kernel.count))
        
        try await MetalFunction(name: "layer_convolution", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newLayer.texture)
            .argument(buffer: _kernel)
            .argument(bytes: SIMD2<Int32>(Int32(kernel.width), Int32(kernel.height)))
            .argument(bytes: components)
            .dispatch(to: self.context, width: self.width, height: self.height)
        
        return newLayer
    }
    
    /// Returns a resized layer using lanczos resample.
    ///
    /// - Note: By returning a new layer, the current layer is unmodified.
    func resized(to size: CGSize) async throws -> Layer {
        let width = Int(size.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(size.height.rounded(.toNearestOrAwayFromZero))
        
        let newLayer = Layer(width: width, height: height, origin: self.origin, colorSpace: self.colorSpace, context: self.context)
        newLayer.texture.label = "Layer.Texture<(\(width), \(height), 4)>(resizeOf: \(self.texture.label ?? "(unknown)"))"
        
        try await MetalFunction(name: "lanczosResample", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newLayer.texture)
            .dispatch(to: self.context, width: width, height: height)
        
        return newLayer
    }
    
    func aspectRatioResize(_ contentMode: ContentMode, in rect: CGRect) async throws -> Layer {
        let size = self.size.aspectRatio(contentMode, in: rect.size)
        let origin = CGRect(center: rect.center, size: size).origin
        
        let layer = try await self.resized(to: size)
        layer.move(to: origin)
        return layer
    }
    
    /// Shift the underlying texture.
    ///
    /// Please note that by shifting the layer, some pixels may be discarded. The new regions will be filled with ``PartialColor/clear``.
    func shifted(x: Int, y: Int) async throws -> Layer {
        let newLayer = Layer(width: self.width, height: self.height, origin: self.origin, colorSpace: self.colorSpace, context: self.context)
        newLayer.texture.label = "Layer.Texture<(\(width), \(height), 4)>(shiftedFrom: \(self.texture.label ?? "(unknown)"))"
        
        try await MetalFunction(name: "layer_duplicate_shift", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newLayer.texture)
            .argument(bytes: SIMD2<Int32>(Int32(x), Int32(y)))
            .dispatch(to: self.context, width: self.width, height: self.height)
        
        return newLayer
    }
    
    /// Shift the underlying texture.
    ///
    /// Please note that by shifting the layer, some pixels may be discarded. The new regions will be filled with ``PartialColor/clear``.
    func shifted(x: some BinaryFloatingPoint, y: some BinaryFloatingPoint) async throws -> Layer {
        let newLayer = Layer(width: self.width, height: self.height, origin: self.origin, colorSpace: self.colorSpace, context: self.context)
        newLayer.texture.label = "Layer.Texture<(\(width), \(height), 4)>(shiftedFrom: \(self.texture.label ?? "(unknown)"))"
        
        try await MetalFunction(name: "layer_duplicate_shift_float", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newLayer.texture)
            .argument(bytes: SIMD2<Float>(Float(x), Float(y)))
            .dispatch(to: self.context, width: self.width, height: self.height)
        
        return newLayer
    }
    
}
