//
//  AspectRatio.swift
//  
//
//  Created by Vaida on 7/7/24.
//


import Stratum
import SwiftUI


public struct AspectRatioTransformation: Transformation {
    
    let contentMode: ContentMode
    
    let containerRect: CGRect
    
    public func apply(layer: Layer) throws {
        let size = layer.size.aspectRatio(contentMode, in: containerRect.size)
        let origin = CGRect(center: containerRect.center, size: size).origin
        
        try ResizeTransformation(size: size).apply(layer: layer)
        layer.move(to: origin)
    }
    
}


public extension Transformation where Self == AspectRatioTransformation {
    
    static func aspectRatio(_ contentMode: ContentMode, in rect: CGRect) -> AspectRatioTransformation {
        AspectRatioTransformation(contentMode: contentMode, containerRect: rect)
    }
    
}
