//
//  Select + Visible.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Metal
import MetalManager


public struct SelectByVisible: SelectionCriteria {
    
    let tolerance: UInt8
    
    public func select(layer: Layer) throws -> Mask {
        let manager = try MetalManager(name: "selectByVisible", fileWithin: .module)
        
        manager.setConstant(layer.width)
        manager.setConstant(tolerance)
        
        let maskLength = (layer.width * layer.height)
        
        try manager.setBuffer(layer.buffer)
        let maskBuffer = try manager.setEmptyBuffer(count: maskLength, type: Bool.self)
        
        try manager.perform(gridSize: MTLSize(width: layer.width, height: layer.height, depth: 1))
        
        return Mask(buffer: maskBuffer, size: layer.frame.size)
    }
    
}


public extension SelectionCriteria where Self == SelectByVisible {
    
    /// The tolerance of 0 would only select pixels with alpha 255.
    ///
    /// The default tolerance is 254, ie, all pixels with non-zero alpha would be selected.
    static func visible(tolerance: UInt8 = 254) -> SelectionCriteria {
        SelectByVisible(tolerance: tolerance)
    }
    
}
