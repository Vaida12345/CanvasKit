//
//  Operations.swift
//  Raw Graphics
//
//  Created by Vaida on 2023/10/11.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

@rethrows
public protocol LayerOperations {
    
    func apply(layer: Layer) throws
    
}


extension Layer {
    
    /// Applies the given operation
    public func apply(_ operation: some LayerOperations) rethrows {
        try operation.apply(layer: self)
    }
    
}
