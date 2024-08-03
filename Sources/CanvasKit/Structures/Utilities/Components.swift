//
//  Components.swift
//  CanvasKit
//
//  Created by Vaida on 8/3/24.
//


public struct Components: OptionSet, Sendable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    
    public static let red    = Components(rawValue: 1 << 0)
    public static let green  = Components(rawValue: 1 << 1)
    public static let blue   = Components(rawValue: 1 << 2)
    public static let alpha  = Components(rawValue: 1 << 3)
    
    
    public static let all: Components = [.red, .green, .blue, .alpha]
    
}
