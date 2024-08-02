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
    
    let components: SIMD4<UInt32>
    
    let presence: SIMD4<UInt32>
    
    
    public var redComponent: UInt8? {
        guard presence[0] != 0 else { return nil }
        return UInt8(self.components[0])
    }
    
    public var greenComponent: UInt8? {
        guard presence[1] != 0 else { return nil }
        return UInt8(self.components[1])
    }
    
    public var blueComponent: UInt8? {
        guard presence[2] != 0 else { return nil }
        return UInt8(self.components[2])
    }
    
    public var alphaComponent: UInt8? {
        guard presence[3] != 0 else { return nil }
        return UInt8(self.components[3])
    }
    
    
    /// Returns a color with the given alpha
    ///
    /// - Parameters:
    ///   - alpha: An alpha of `0` indicates transparent, while `255` indicates full color.
    public func opacity(_ alpha: UInt8?) -> PartialColor {
        PartialColor(red: self.redComponent, green: self.greenComponent, blue: self.blueComponent, alpha: alpha)
    }
    
    /// Creates the color.
    ///
    /// - Parameters:
    ///   - alpha: An alpha of `0` indicates transparent, while `255` indicates full color.
    public init(red: UInt8?, green: UInt8?, blue: UInt8?, alpha: UInt8?) {
        let red_value = UInt32(red ?? 0)
        let red_presence: UInt32 = red != nil ? 1 : 0
        
        let green_value = UInt32(green ?? 0)
        let green_presence: UInt32 = green != nil ? 1 : 0
        
        let blue_value = UInt32(blue ?? 0)
        let blue_presence: UInt32 = blue != nil ? 1 : 0
        
        let alpha_value = UInt32(alpha ?? 0)
        let alpha_presence: UInt32 = alpha != nil ? 1 : 0
        
        self.components = SIMD4(red_value, green_value, blue_value, alpha_value)
        self.presence = SIMD4(red_presence, green_presence, blue_presence, alpha_presence)
    }
    
    public init(_ color: SwiftUI.Color) {
        let color = color.animatableData
        self.init(
            red: UInt8(color[0] * 255),
            green: UInt8(color[1] * 255),
            blue: UInt8(color[2] * 255),
            alpha: UInt8(color[3] * 255)
        )
    }
    
    public static let white = PartialColor(red: 255, green: 255, blue: 255, alpha: 255)
    public static let black = PartialColor(red: 0,   green: 0,   blue: 0,   alpha: 255)
    public static let clear = PartialColor(red: 0,   green: 0,   blue: 0,   alpha: 0)
    
    public static let red   = PartialColor(red: 255, green: 0,   blue: 0,   alpha: 255)
    public static let green = PartialColor(red: 0,   green: 255, blue: 0,   alpha: 255)
    public static let blue  = PartialColor(red: 0,   green: 0,   blue: 255, alpha: 255)
}
