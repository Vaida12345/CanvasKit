//
//  Color.swift
//  Raw Graphics
//
//  Created by Vaida on 2023/10/11.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import Foundation


/// The color in `UInt8`.
public struct Color: Equatable {
    
    public var red: UInt8
    
    public var green: UInt8
    
    public var blue: UInt8
    
    /// Alpha value
    ///
    /// An alpha of `0` indicates transparent, while `255` indicates full color.
    public var alpha: UInt8
    
    
    /// Returns a color with the given alpha
    ///
    /// - Parameters:
    ///   - alpha: An alpha of `0` indicates transparent, while `255` indicates full color.
    public func opacity(_ alpha: UInt8) -> Color {
        Color(red: self.red, green: self.green, blue: self.blue, alpha: alpha)
    }
    
    
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    
    static let allKeyPaths: [WritableKeyPath<Color, UInt8>] = [\.red, \.green, \.blue, \.alpha]
    static let colorKeyPaths: [WritableKeyPath<Color, UInt8>] = [\.red, \.green, \.blue]
    
    public static let white: Color = Color(red: 255, green: 255, blue: 255)
    public static let black: Color = Color(red: 0,   green: 0,   blue: 0)
    public static let clear: Color = Color(red: 0,   green: 0,   blue: 0, alpha: 0)
    
    public static let red:   Color = Color(red: 255, green: 0,   blue: 0)
    public static let green: Color = Color(red: 0,   green: 255, blue: 0)
    public static let blue:  Color = Color(red: 0,   green: 0,   blue: 255)
}
