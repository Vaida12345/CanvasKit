//
//  Transform + Protocol.swift
//  
//
//  Created by Vaida on 7/7/24.
//

public protocol Transformation {
    
    func apply(layer: Layer) throws
    
}


extension Layer {
    
    public func transform(_ transformation: Transformation) throws {
        try transformation.apply(layer: self)
    }
    
}
