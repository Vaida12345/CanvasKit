//
//  Select + Visible.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import MetalManager


public struct SelectByVisible: SelectionCriteria {
    
    public func select(layer: Layer) async throws -> Mask {
        let texture = Mask.makeTexture(width: layer.width, height: layer.height)
        
        try await MetalFunction(name: "layer_selectByVisible", bundle: .module)
            .argument(texture: layer.texture)
            .argument(texture: texture)
            .dispatch(to: layer.context, width: layer.width, height: layer.height)
        
        return Mask(texture: texture, context: layer.context)
    }
    
}


public extension SelectionCriteria where Self == SelectByVisible {
    
    /// Select by visible.
    ///
    /// This will copy the alpha layer to the mask.
    static func visible() -> SelectionCriteria {
        SelectByVisible()
    }
    
}
