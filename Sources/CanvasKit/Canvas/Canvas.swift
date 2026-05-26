//
//  Canvas.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import CoreGraphics
import MetalManager
import Metal
import NativeImage


enum CanvasError: Error {
    case argumentEncoderCreationFailed
    case argumentBufferCreationFailed
}


/// A canvas, made up of images.
///
/// - Important: You need to ensure that all layers of the same canvas share the same `MetalContext`.
///
/// A canvas does not contain size information, it only provides a coordinate space. All layer's `origin` are relative to the same coordinate space. In the coordinate space of `CanvasKit`, the origin lies on the top-left corner.
public final class Canvas {
    
    /// ordered from bottom to top.
    public var layers: [Layer]
    
    
    /// Composites all layers into a single output layer.
    ///
    /// - Parameters:
    ///   - width: The width of the output layer.
    ///   - height: The height of the output layer.
    ///   - context: The context used to schedule the composite pass.
    ///
    /// Layers that do not intersect the output bounds are culled before compositing.
    public func makeLayer(width: Int, height: Int, context: MetalContext) async throws -> Layer {
        let size = CGSize(width: width, height: height)
        let outputRect = CGRect(origin: .zero, size: size)
        let visibleLayers = layers.filter { $0.frame.intersects(outputRect) }
        
        guard !visibleLayers.isEmpty else {
            return Layer(width: width, height: height, context: context)
        }
        
        if visibleLayers.count == 1,
           let layer = visibleLayers.first {
            return try await layer.expanding(to: CGRect(origin: -layer.origin, size: size))
        }
        
        let device = CanvasKitConfiguration.computeDevice
        
        let descriptor = MTLArgumentDescriptor()
        descriptor.dataType = .texture
        descriptor.index = 0
        descriptor.access = .readWrite
        descriptor.arrayLength = visibleLayers.count
        descriptor.textureType = .type2D
        
        guard let encoder = device.makeArgumentEncoder(arguments: [descriptor]) else {
            throw CanvasError.argumentEncoderCreationFailed
        }
        encoder.label = "ArgumentEncoder(for \(#function))"
        guard let argumentBuffer = device.makeBuffer(length: encoder.encodedLength) else {
            throw CanvasError.argumentBufferCreationFailed
        }
        encoder.setArgumentBuffer(argumentBuffer, offset: 0)
        
        for (index, layer) in visibleLayers.enumerated() {
            encoder.setTexture(layer.texture, index: index)
        }
        
        let origins = visibleLayers.map { layer in
            SIMD2<Float>(Float(layer.origin.x), Float(layer.origin.y))
        }
        let buffer = try origins.withUnsafeBufferPointer { buffer in
            try device.makeBuffer(bytes: UnsafeMutableBufferPointer(mutating: buffer))
        }
        
        let resultLayer = Layer(width: width, height: height, context: context)
        
        try await MetalFunction(name: "canvas_make_texture", bundle: .module)
            .argument(buffer: argumentBuffer)
            .argument(buffer: buffer)
            .argument(bytes: Int32(visibleLayers.count))
            .argument(texture: resultLayer.texture)
            .dispatch(to: context, width: width, height: height)
        
        return resultLayer
    }
    
    /// Insert a layer at the top
    public func add(layer: Layer, at index: Int? = nil) {
        if let index {
            self.layers.insert(layer, at: index)
        } else {
            self.layers.append(layer)
        }
    }
    
    public func replace(layerAt index: Int, with newLayer: Layer) {
        self.layers[index] = newLayer
    }
    
    /// - layers: ordered from bottom to top.
    public init(layers: [Layer] = []) {
        self.layers = layers
    }
    
    public convenience init(layer: Layer) {
        self.init(layers: [layer])
    }
    
}
