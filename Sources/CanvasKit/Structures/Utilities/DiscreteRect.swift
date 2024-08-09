//
//  DiscreteRect.swift
//  CanvasKit
//
//  Created by Vaida on 7/30/24.
//

import CoreGraphics


struct DiscreteRect {
    
    let origin: SIMD2<Int32>
    
    let size: SIMD2<Int32>
    
    
    init(_ rect: CGRect) {
        self.origin = SIMD2(Int32(rect.origin.x.rounded(.toNearestOrAwayFromZero)),   Int32(rect.origin.y.rounded(.toNearestOrAwayFromZero)))
        self.size   = SIMD2(Int32(rect.size.width.rounded(.toNearestOrAwayFromZero)), Int32(rect.size.height.rounded(.toNearestOrAwayFromZero)))
    }
    
}
