//
//  Select + Color.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import MetalManager


public struct SelectByColor: SelectionCriteria {
    
    let color: PartialColor
    
    let tolerance: Float
    
    
    public func select(layer: Layer) async throws -> Mask {
        let texture = Mask.makeTexture(width: layer.width, height: layer.height)
        
        try await MetalFunction(name: "layer_selectByColor", bundle: .module)
            .argument(texture: layer.texture)
            .argument(texture: texture)
            .argument(bytes: tolerance)
            .argument(bytes: color)
            .dispatch(to: layer.context.addJob(), width: layer.width, height: layer.height)
        
        return Mask(texture: texture, context: layer.context)
    }
    
}


public extension SelectionCriteria where Self == SelectByColor {
    
    /// Select by color.
    ///
    /// - Parameters:
    ///   - color: If a component is `nil`, that criteria is ignored.
    static func color(_ color: PartialColor, tolerance: Float = 0.01) -> SelectByColor {
        SelectByColor(color: color, tolerance: tolerance)
    }
    
}
