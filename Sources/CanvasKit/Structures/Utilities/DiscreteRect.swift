//
//  DiscreteRect.swift
//  CanvasKit
//
//  Created by Vaida on 7/30/24.
//

import CoreGraphics


struct DiscreteRect {
    
    let origin: SIMD2<UInt32>
    
    let size: SIMD2<UInt32>
    
    
    init(origin: SIMD2<UInt32>, size: SIMD2<UInt32>) {
        self.origin = origin
        self.size = size
    }
    
    init(_ rect: CGRect) {
        self.origin = SIMD2(UInt32(rect.origin.x),   UInt32(rect.origin.y))
        self.size   = SIMD2(UInt32(rect.size.width), UInt32(rect.size.height))
    }
    
}
