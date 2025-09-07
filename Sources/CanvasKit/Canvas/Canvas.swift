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


/// A canvas, made up of images.
///
/// - Important: You need to ensure that all layers of the same canvas share the same `MetalContext`.
///
/// A canvas does not contain size information, it only provides a coordinate space. All layer's `origin` are relative to the same coordinate space. In the coordinate space of `CanvasKit`, the origin lies on the top-left corner.
public final class Canvas {
    
    /// The newer layers are on top.
    public var layers: [Layer]
    
    
    public func makeLayer(width: Int, height: Int, context: MetalContext) async throws -> Layer {
        let size = CGSize(width: width, height: height)
        
        if layers.count == 1,
           let layer = layers.first {
            return try await layer.expanding(to: CGRect(origin: -layer.origin, size: size))
        }
        
        let device = CanvasKitConfiguration.computeDevice
        
        let descriptor = MTLArgumentDescriptor()
        descriptor.dataType = .texture
        descriptor.index = 0
        descriptor.access = .readWrite
        descriptor.arrayLength = layers.count
        descriptor.textureType = .type2D
        
        let encoder = device.makeArgumentEncoder(arguments: [descriptor])!
        encoder.label = "ArgumentEncoder(for \(#function))"
        let argumentBuffer = device.makeBuffer(length: encoder.encodedLength)!
        encoder.setArgumentBuffer(argumentBuffer, offset: 0)
        
        for (index, layer) in self.layers.enumerated() {
            encoder.setTexture(layer.texture, index: index)
        }
        
        let originsBuffer = UnsafeMutableBufferPointer<SIMD2<Float>>.allocate(capacity: layers.count)
        
        for (index, layer) in self.layers.enumerated() {
            originsBuffer.initializeElement(at: index, to: SIMD2(Float(layer.origin.x),
                                                                 Float(layer.origin.y)))
        }
        let buffer = try device.makeBuffer(bytes: originsBuffer)
        originsBuffer.deallocate()
        
        let resultLayer = Layer(width: width, height: height, context: context)
        
        try await MetalFunction(name: "canvas_make_texture", bundle: .module)
            .argument(buffer: argumentBuffer)
            .argument(buffer: buffer)
            .argument(bytes: Int32(self.layers.count))
            .argument(texture: resultLayer.texture)
            .dispatch(to: context, width: width, height: height)
        
        return resultLayer
    }
    
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
    
    public init(layers: [Layer] = []) {
        self.layers = layers
    }
    
    public convenience init(layer: Layer) {
        self.init(layers: [layer])
    }
    
}
