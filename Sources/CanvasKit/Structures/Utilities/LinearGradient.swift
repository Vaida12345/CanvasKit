//
//  LinearGradient.swift
//  CanvasKit
//
//  Created by Vaida on 2025-09-06.
//


public struct LinearGradient: Equatable, Sendable {
    
    public let startColor: PartialColor
    
    public let endColor: PartialColor
    
    public let direction: Direction
    
    
    public enum Direction: UInt8, Equatable, Sendable {
        case horizontal, vertical
    }
}
