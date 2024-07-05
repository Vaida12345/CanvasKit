//
//  Select + Visible.swift
//  
//
//  Created by Vaida on 7/5/24.
//


public struct SelectByVisible: SelectionCriteria {
    
    let tolerance: UInt8
    
    public func select(layer: Layer) throws -> Mask {
        fatalError()
    }
    
}


extension SelectionCriteria where Self == SelectByVisible {
    
    /// The tolerance of 0 would would select pixels with alpha 255.
    public static func visible(tolerance: UInt8) -> SelectionCriteria {
        SelectByVisible(tolerance: tolerance)
    }
    
}
