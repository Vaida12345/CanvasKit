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
public final class Mask: LayerProtocol, @unchecked Sendable {
    
    /// Each pixel would take one byte. It is a waste, but could avoid metal data racing.
    public let texture: any MTLTexture
    
    var width: Int {
        self.texture.width
    }
    
    var height: Int {
        self.texture.height
    }
    
    let context: MetalContext
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    private var _isEmpty: MetalDependentState<Bool>? = nil
    
    public func isEmpty() async throws -> MetalDependentState<Bool> {
        if let _isEmpty { return _isEmpty }
        
        let state = MetalDependentState(initialValue: true, context: context)
        
        try await MetalFunction(name: "mask_check_full_zeros", bundle: .module)
            .argument(texture: self.texture)
            .argument(state: state)
            .dispatch(to: context.addJob(), width: self.width, height: self.height)
        
        self._isEmpty = state
        
        return state
    }
    
    
    private var _boundary: Boundary? = nil
    
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
    public func boundary() async throws -> Boundary {
        if let _boundary { return _boundary }
        
        nonisolated(unsafe)
        let rows = try MetalManager.computeDevice.makeBuffer(of: Bool.self, count: self.height)
        nonisolated(unsafe)
        let columns = try MetalManager.computeDevice.makeBuffer(of: Bool.self, count: self.width)
        
        try await MetalFunction(name: "mask_check_zeros_by_rows_columns", bundle: .module)
            .argument(texture: self.texture)
            .argument(buffer: rows)
            .argument(buffer: columns)
            .dispatch(to: self.context.addJob(), width: self.width, height: self.height)
        
        return Boundary(context: self.context, rows: rows, columns: columns, rowsCount: self.height, columnsCount: self.width)
    }
    
    
    public func invert() async throws -> Mask {
        let newTexture = Mask.makeTexture(width: self.width, height: self.height)
        
        try await MetalFunction(name: "mask_duplicate_inverse", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newTexture)
            .dispatch(to: self.context.addJob(), width: self.width, height: self.height)
        
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
    public func expanding(to rect: CGRect) async throws -> Mask {
        let width = Int(rect.width)
        let height = Int(rect.height)
        
        let newTexture = Mask.makeTexture(width: width, height: height)
        newTexture.label = "Mask.Texture<(\(width), \(height))>(expandOf: \(self.texture.label ?? "(unknown)"), by: \(rect))"
        
        try await MetalFunction(name: "mask_expand", bundle: .module)
            .argument(texture: self.texture)
            .argument(texture: newTexture)
            .argument(bytes: DiscreteRect(rect))
            .dispatch(to: self.context.addJob(), width: self.width, height: self.height)
        
        return Mask(texture: newTexture, context: self.context)
    }
    
    public func makeContext() async throws -> CGContext {
        try await self.context.synchronize()
        let contents = self.texture.makeBuffer(channelsCount: 1)
        
        return CGContext(
            data: contents.baseAddress!,
            width: self.width,
            height: self.height,
            bitsPerComponent: 8,
            bytesPerRow: self.width * 1,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
    }
    
    init(texture: any MTLTexture, context: MetalContext) {
        self.texture = texture
        self.context = context
    }
    
    private static func makeTexture(width: Int, height: Int) -> any MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.height = height
        descriptor.width = width
        descriptor.pixelFormat = .r8Uint
        descriptor.usage = .shaderReadWrite
        descriptor.storageMode = .shared
        
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
            .argument(bytes: UInt32(uint8))
            .dispatch(to: context.addJob(), width: width, height: height)
        
        texture.label = "Mask.Texture<(\(width), \(height))>(origin: \(#function))"
        self.init(texture: texture, context: context)
    }
    
    /// Creates a mask that selects the `selection`.
    public convenience init(width: Int, height: Int, selecting selection: CGRect, context: MetalContext) async throws {
        let texture = Mask.makeTexture(width: width, height: height)
        
        try await MetalFunction(name: "mask_fill_with_selection", bundle: .module)
            .argument(texture: texture)
            .argument(bytes: DiscreteRect(selection))
            .dispatch(to: context.addJob(), width: width, height: height)
        
        texture.label = "Mask.Texture<(\(width), \(height))>(origin: \(#function))"
        self.init(texture: texture, context: context)
    }
    
}
