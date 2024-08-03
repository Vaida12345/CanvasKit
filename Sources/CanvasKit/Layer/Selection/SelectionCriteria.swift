//
//  SelectionCriteria.swift
//  
//
//  Created by Vaida on 7/5/24.
//


public protocol SelectionCriteria {
    
    func select(layer: Layer) async throws -> Mask
    
}


extension Layer {
    
    public func select(by criteria: SelectionCriteria = .visible()) async throws -> Mask {
        try await criteria.select(layer: self)
    }
    
}
