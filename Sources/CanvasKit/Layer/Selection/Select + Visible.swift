//
//  Select + Visible.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import MetalManager


public struct SelectByVisible: SelectionCriteria {
    
    let tolerance: Float16
    
    public func select(layer: Layer) async throws -> Mask {
        let texture = Mask.makeTexture(width: layer.width, height: layer.height)
        
        try await MetalFunction(name: "layer_selectByVisible", bundle: .module)
            .argument(texture: layer.texture)
            .argument(texture: texture)
            .argument(bytes: tolerance)
            .dispatch(to: layer.context, width: layer.width, height: layer.height)
        
        return Mask(texture: texture, context: layer.context)
    }
    
}


public extension SelectionCriteria where Self == SelectByVisible {
    
    /// The tolerance of 0 would only select pixels with alpha 255.
    ///
    /// The default tolerance is 254, ie, all pixels with non-zero alpha would be selected.
    static func visible(tolerance: Float16 = 0.95) -> SelectionCriteria {
        SelectByVisible(tolerance: tolerance)
    }
    
}
