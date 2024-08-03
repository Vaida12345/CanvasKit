//
//  Canvas.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import CoreGraphics
import MetalManager
import Metal
import GraphicsKit


/// A canvas, made up of images.
///
/// - Important: You need to ensure that all layers of the same canvas share the same `MetalContext`.
public final class Canvas {
    
    /// The newer layers are on top.
    public var layers: [Layer]
    
    
    public func makeTexture(width: Int, height: Int, context: MetalContext) async throws -> any MTLTexture {
        let size = CGSize(width: width, height: height)
        
        if layers.count == 1,
           let layer = layers.first {
            return try await layer.expanding(to: CGRect(origin: -layer.origin, size: size)).makeTexture()
        }
        
        let device = CanvasKitConfiguration.computeDevice
        
        let descriptor = MTLArgumentDescriptor()
        descriptor.dataType = .texture
        descriptor.index = 0
        descriptor.access = .readOnly
        descriptor.arrayLength = layers.count
        descriptor.textureType = .type2D
        
        let encoder = device.makeArgumentEncoder(arguments: [descriptor])!
        let argumentBuffer = device.makeBuffer(length: encoder.encodedLength)!
        encoder.setArgumentBuffer(argumentBuffer, offset: 0)
        
        for (index, layer) in self.layers.enumerated() {
            encoder.setTexture(layer.texture, index: index)
        }
        
        let originsBuffer = UnsafeMutableBufferPointer<Int32>.allocate(capacity: layers.count * 2)
        
        for (index, layer) in self.layers.enumerated() {
            originsBuffer.initializeElement(at: 2 * index, to: Int32(layer.origin.x))
            originsBuffer.initializeElement(at: 2 * index + 1, to: Int32(layer.origin.y))
        }
        let buffer = try device.makeBuffer(bytes: originsBuffer)
        originsBuffer.deallocate()
        
        let resultLayer = Layer(width: width, height: height, context: context)
        
        try await MetalFunction(name: "canvas_make_texture", bundle: .module)
            .argument(buffer: argumentBuffer)
            .argument(buffer: buffer)
            .argument(bytes: Int32(self.layers.count))
            .argument(texture: resultLayer.texture)
            .dispatch(to: context.addJob(), width: width, height: height)
        
        return try await resultLayer.makeTexture()
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
