//
//  Select + Color.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import MetalManager
import Metal


public struct SelectByColor: SelectionCriteria {
    
    let color: PartialColor
    
    let tolerance: Float
    
    let N: Int
    
    
    public func select(layer: Layer) async throws -> Mask {
        let texture = Mask.makeTexture(width: layer.width, height: layer.height)
        
        let samplerDesc = MTLSamplerDescriptor()
        samplerDesc.minFilter     = .nearest
        samplerDesc.magFilter     = .nearest
        samplerDesc.mipFilter     = .notMipmapped
        samplerDesc.sAddressMode  = .clampToEdge
        samplerDesc.tAddressMode  = .clampToEdge
        
        try await MetalFunction(name: "layer_selectByColor", bundle: .module)
            .argument(texture: layer.texture)
            .argument(texture: texture)
            .argument(bytes: tolerance)
            .argument(bytes: color)
            .argument(bytes: N)
            .argument(sampler: samplerDesc)
            .dispatch(to: layer.context, width: layer.width, height: layer.height)
        
        return Mask(texture: texture, context: layer.context)
    }
    
}


public extension SelectionCriteria where Self == SelectByColor {
    
    /// Select by color.
    ///
    /// - Parameters:
    ///   - color: If a component is `nil`, that criteria is ignored.
    ///   - sampleSize: Each pixel will be sampled `sampleSize` times to ensure a smooth edge.
    static func color(_ color: PartialColor, tolerance: Float = 0.01, sampleSize: Int = 3) -> SelectByColor {
        SelectByColor(color: color, tolerance: tolerance, N: sampleSize)
    }
    
}
