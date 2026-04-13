//
//  Mask.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Metal
import Foundation
import MetalManager
import CoreGraphics


/// An immutable mask.
///
/// This container is tightly bound to the underlying texture. Its texture is allocated on creation, and the texture, including its content, cannot be changed.
///
/// Each pixel is an `UInt8` representing from clear color, 0, to fully masked, 255.
///
/// On `Swift` end, each pixel is an `UInt8`, while on `MSL`, each pixel is a `half` ranging from 0 to 1.
public final class Mask: LayerProtocol, @unchecked Sendable {
    
    /// Each pixel would take one byte. It is a waste, but could avoid metal data racing.
    public let texture: any MTLTexture
    
    /// The width of the texture.
    public var width: Int {
        self.texture.width
    }
    
    /// The height of the texture.
    public var height: Int {
        self.texture.height
    }
    
    public let context: MetalContext
    
    /// The size of the texture.
    public var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    /// Is fully zero.
    private var _isEmpty: MetalDependentState<Bool>? = nil
    
    /// Is fully zero.
    public func isEmpty() async throws -> MetalDependentState<Bool> {
        if let _isEmpty { return _isEmpty }
        
        let state = MetalDependentState(initialValue: true, context: context)
        
        try await MetalFunction(name: "mask_check_full_zeros", bundle: .module)
            .argument(texture: self.texture)
            .argument(state: state)
            .dispatch(to: context, width: self.width, height: self.height)
        
        self._isEmpty = state
        
        return state
    }
    
    
    private var _boundary: CGRect? = nil
    
    /// The boundary of the mask.
    ///
    /// For a mask of
    /// ```
    /// 0 0 0 0
    /// 0 1 1 0
    /// 0 1 1 0
    /// 0 0 0 0
    /// ```
    /// the boundary is `CGRect(x: 1, y: 1, width: 2, height: 2)`.
    ///
    /// - Complexity: **Calling this method would synchronize the context.** One could have chosen to return a `MetalDependentState`, and calculate the rect when required. But that would not make any differences. The return boundary is mainly used by the CPU to compute the actual size of the buffer, and create new buffers out of it. One way or another, the CPU must know the size of the boundary to allocate the textures.
    public func boundary() async throws -> CGRect {
        if let _boundary { return _boundary }

        nonisolated(unsafe)
        let rows = try CanvasKitConfiguration.computeDevice.makeBuffer(of: Bool.self, count: self.height)
        nonisolated(unsafe)
        let columns = try CanvasKitConfiguration.computeDevice.makeBuffer(of: Bool.self, count: self.width)

        rows.contents().initializeMemory(as: UInt8.self, repeating: 0, count: rows.length)
        columns.contents().initializeMemory(as: UInt8.self, repeating: 0, count: columns.length)

        try await MetalFunction(name: "mask_check_zeros_by_rows_columns", bundle: .module)
            .argument(texture: self.texture)
            .argument(buffer: rows)
            .argument(buffer: columns)
            .dispatch(to: self.context, width: self.width, height: self.height)

        try await context.synchronize()

        let _rows = UnsafeMutableBufferPointer(start: rows.contents().assumingMemoryBound(to: Bool.self), count: self.height)
        let _columns = UnsafeMutableBufferPointer(start: columns.contents().assumingMemoryBound(to: Bool.self), count: self.width)

        guard let xStart = _columns.firstIndex(of: true),
              let xEnd = _columns.lastIndex(of: true),
              let yStart = _rows.firstIndex(of: true),
              let yEnd = _rows.lastIndex(of: true) else {
            let boundary = CGRect.zero
            self._boundary = boundary
            return boundary
        }

        let boundary = CGRect(x: xStart, y: yStart, width: xEnd - xStart + 1, height: yEnd - yStart + 1)
        self._boundary = boundary
        return boundary
    }
    
    
    public func invert() async throws -> Mask {
        let newTexture = Mask.makeTexture(width: self.width, height: self.height)
        
        try await MetalFunction(name: "mask_duplicate_inverse", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newTexture)
            .dispatch(to: self.context, width: self.width, height: self.height)
        
        newTexture.label = "Mask.Texture<(\(width), \(height))>(inverseOf: \(self.texture.label ?? "(unknown)"))"
        return Mask(texture: newTexture, context: self.context)
    }
    
    /// Expand the Mask.
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
    ///
    /// Uses an integer-copy fast path when the origin rounds exactly to integral coordinates.
    public func expanding(to rect: CGRect) async throws -> Mask {
        let width = Int(rect.width.rounded(.toNearestOrAwayFromZero))
        let height = Int(rect.height.rounded(.toNearestOrAwayFromZero))
        
        let newTexture = Mask.makeTexture(width: width, height: height)
        newTexture.label = "Mask.Texture<(\(width), \(height))>(expandOf: \(self.texture.label ?? "(unknown)"), by: \(rect))"
        
        let roundedX = rect.origin.x.rounded(.toNearestOrAwayFromZero)
        let roundedY = rect.origin.y.rounded(.toNearestOrAwayFromZero)
        let isIntegerOrigin = rect.origin.x == roundedX && rect.origin.y == roundedY
        
        if isIntegerOrigin {
            try await MetalFunction(name: "mask_expand_int", bundle: .module)
                .argument(texture: self.texture)
                .argument(texture: newTexture)
                .argument(bytes: SIMD2<Int32>(Int32(roundedX), Int32(roundedY)))
                .dispatch(to: self.context, width: width, height: height)
        } else {
            try await MetalFunction(name: "mask_expand", bundle: .module)
                .argument(texture: self.texture)
                .argument(texture: newTexture)
                .argument(bytes: SIMD2<Float>(Float(rect.origin.x), Float(rect.origin.y)))
                .dispatch(to: self.context, width: width, height: height)
        }
        
        // Expanding can introduce or remove visible pixels depending on overlap, so caches are invalidated.
        return Mask(texture: newTexture, context: self.context)
    }
    
    /// Crop the Mask.
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
    public func cropping(to rect: CGRect) async throws -> Mask {
        try await self.expanding(to: rect)
    }
    
    /// Quantize the mask.
    ///
    /// - Parameters:
    ///   - threshold: If pixel value is greater than `threshold`, the pixel is set to 255.
    public func quantized(threshold: Float) async throws -> Mask {
        let newTexture = Mask.makeTexture(width: self.width, height: self.height)
        
        try await MetalFunction(name: "mask_quantize", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newTexture)
            .argument(bytes: threshold)
            .dispatch(to: self.context, width: self.width, height: self.height)
        
        newTexture.label = "Mask.Texture<(\(width), \(height))>(quantizedFrom: \(self.texture.label ?? "(unknown)"))"
        // Quantization changes occupancy and boundary, so cached derived values cannot be reused.
        return Mask(texture: newTexture, context: self.context)
    }
    
    public func render() async throws -> CGImage {
        try await self.makeTexture().makeCGImage(channelsCount: 1, colorSpace: CGColorSpaceCreateDeviceGray(), bitmapInfo: .none)
    }
    
    init(texture: any MTLTexture, context: MetalContext, _isEmpty: MetalDependentState<Bool>? = nil, _boundary: CGRect? = nil) {
        self.texture = texture
        self.context = context
        
        self._isEmpty = _isEmpty
        self._boundary = _boundary
    }
    
    static func makeTexture(width: Int, height: Int) -> any MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.height = height
        descriptor.width = width
        descriptor.pixelFormat = .r8Unorm
        descriptor.usage = .shaderReadWrite
        descriptor.storageMode = .private
        
        let device = CanvasKitConfiguration.computeDevice
        return device.makeTexture(descriptor: descriptor)!
    }
    
    /// Creates a mask.
    ///
    /// - Parameters:
    ///   - uint8: The mask value. A value of zero would indicate not selected, while any none-zero value would indicate the given pixel is selected.
    public convenience init(repeating uint8: UInt8 = 0, width: Int, height: Int, context: MetalContext) async throws {
        let texture = Mask.makeTexture(width: width, height: height)
        
        try await MetalFunction(name: "mask_fill_with", bundle: .module)
            .argument(texture: texture)
            .argument(bytes: uint8)
            .dispatch(to: context, width: width, height: height)
        
        texture.label = "Mask.Texture<(\(width), \(height))>(origin: \(#function))"
        self.init(texture: texture, context: context)
    }
    
    /// Creates a mask that selects the `selection`.
    public convenience init(width: Int, height: Int, selecting selection: CGRect, context: MetalContext) async throws {
        let texture = Mask.makeTexture(width: width, height: height)
        
        try await MetalFunction(name: "mask_fill_with_selection", bundle: .module)
            .argument(texture: texture)
            .argument(bytes: DiscreteRect(selection))
            .dispatch(to: context, width: width, height: height)
        
        texture.label = "Mask.Texture<(\(width), \(height))>(origin: \(#function))"
        self.init(texture: texture, context: context)
    }
    
}
