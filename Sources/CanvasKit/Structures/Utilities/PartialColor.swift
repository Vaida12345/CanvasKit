//
//  PartialColor.swift
//
//
//  Created by Vaida on 2023/10/11.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import Foundation
import SwiftUI


/// The color in `UInt8`.
public struct PartialColor: Equatable, Sendable {
    
    let components: SIMD4<Float>
    
    let presence: SIMD4<UInt32>
    
    
    public var redComponent: Float? {
        guard presence[0] != 0 else { return nil }
        return self.components[0]
    }
    
    public var greenComponent: Float? {
        guard presence[1] != 0 else { return nil }
        return self.components[1]
    }
    
    public var blueComponent: Float? {
        guard presence[2] != 0 else { return nil }
        return self.components[2]
    }
    
    /// An alpha of `0` indicates transparent, while `1` indicates full color.
    public var alphaComponent: Float? {
        guard presence[3] != 0 else { return nil }
        return self.components[3]
    }
    
    
    /// Returns a color with the given alpha
    ///
    /// - Parameters:
    ///   - alpha: An alpha of `0` indicates transparent, while `1` indicates full color.
    public func opacity(_ alpha: Float?) -> PartialColor {
        PartialColor(red: self.redComponent, green: self.greenComponent, blue: self.blueComponent, alpha: alpha)
    }
    
    /// Creates the color.
    ///
    /// - Parameters:
    ///   - alpha: An alpha of `0` indicates transparent, while `255` indicates full color.
    public init(red: Float?, green: Float?, blue: Float?, alpha: Float?) {
        let red_value = red ?? 0
        let red_presence: UInt32 = red != nil ? 1 : 0
        
        let green_value = green ?? 0
        let green_presence: UInt32 = green != nil ? 1 : 0
        
        let blue_value = blue ?? 0
        let blue_presence: UInt32 = blue != nil ? 1 : 0
        
        let alpha_value = alpha ?? 0
        let alpha_presence: UInt32 = alpha != nil ? 1 : 0
        
        self.components = SIMD4(red_value, green_value, blue_value, alpha_value)
        self.presence = SIMD4(red_presence, green_presence, blue_presence, alpha_presence)
    }
    
    public init(_ color: SwiftUI.Color) {
        let color = color.animatableData
        self.init(
            red: Float(color[0]),
            green: Float(color[1]),
            blue: Float(color[2]),
            alpha: Float(color[3])
        )
    }
    
    public static let white = PartialColor(red: 1, green: 1, blue: 1, alpha: 1)
    public static let black = PartialColor(red: 0, green: 0, blue: 0, alpha: 1)
    public static let clear = PartialColor(red: 0, green: 0, blue: 0, alpha: 0)
    
    public static let red   = PartialColor(red: 1, green: 0, blue: 0, alpha: 1)
    public static let green = PartialColor(red: 0, green: 1, blue: 0, alpha: 1)
    public static let blue  = PartialColor(red: 0, green: 0, blue: 1, alpha: 1)
}
