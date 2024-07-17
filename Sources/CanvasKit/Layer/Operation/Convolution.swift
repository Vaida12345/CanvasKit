//
//  Convolution.swift
//  Raw Graphics
//
//  Created by Vaida on 2023/11/06.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import Metal
import MetalManager
import Stratum
import Accelerate


public struct ConvolutionOperation: LayerOperations {
    
    
    let kernel: Matrix<Float>
    
    let layers: Layers
    
    
    public func apply(layer: Layer) throws {
        let manager = try MetalManager(name: "convolution", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        
        //FIXME: only consider odd matrix for now
        let leftPaddingCount = kernel.width / 2
        let rightPaddingCount = kernel.width - 1 - leftPaddingCount
        let topPaddingCount = kernel.height / 2
        let bottomPaddingCount = kernel.height - 1 - topPaddingCount
        
        manager.setConstant(layer.width)
        manager.setConstant(layer.height)
        manager.setConstant(kernel.width)
        manager.setConstant(kernel.height)
        
        manager.setConstant(leftPaddingCount)
        manager.setConstant(rightPaddingCount)
        manager.setConstant(topPaddingCount)
        manager.setConstant(bottomPaddingCount)
        
        manager.setConstant(layers.rawValue)
        
        
        try manager.setBuffer(layer.buffer)
        try manager.setBuffer(kernel.pointer, length: kernel.count)
        let buffer = try manager.setEmptyBuffer(count: layer.width * layer.height * 4, type: UInt8.self)
        
        try manager.perform(gridSize: MTLSize(width: layer.width, height: layer.height, depth: 4))
        
        layer.set(buffer: buffer, frame: layer.frame)
    }
    
    
    public struct Layers: OptionSet {
        
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        
        public static let red    = Layers(rawValue: 1 << 0)
        public static let green  = Layers(rawValue: 1 << 1)
        public static let blue   = Layers(rawValue: 1 << 2)
        public static let alpha  = Layers(rawValue: 1 << 3)
        
        
        public static let all: Layers = [.red, .green, .blue, .alpha]
        
    }
    
}


extension LayerOperations where Self == ConvolutionOperation {
    
    /// Apply the `kernel` to the image matrix using reflective padding.
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
    public static func convolution(kernel: Matrix<Float>, layers: ConvolutionOperation.Layers = .all) -> ConvolutionOperation {
        return ConvolutionOperation(kernel: kernel, layers: layers)
    }
    
}
