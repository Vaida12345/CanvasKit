//
//  SelectionCriteria.swift
//  
//
//  Created by Vaida on 7/5/24.
//



@rethrows
public protocol SelectionCriteria {
    
    func select(layer: Layer) throws -> Mask
    
}


extension Layer {
    
    public func select(by criteria: SelectionCriteria = .visible(tolerance: 0)) throws -> Mask {
        try criteria.select(layer: self)
    }
    
}
