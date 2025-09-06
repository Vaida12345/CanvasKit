//
//  LinearGradient.swift
//  CanvasKit
//
//  Created by Vaida on 2025-09-06.
//


public struct LinearGradient: Equatable, Sendable {
    
    public let startColor: PartialColor
    
    public let endColor: PartialColor
    
    let _direction: SIMD4<Int32> // for alignment
    
    public var direction: Direction {
        Direction(rawValue: _direction[0])!
    }
    
    
    public init(start: PartialColor, end: PartialColor, direction: Direction) {
        precondition(start.presence == end.presence)
        
        self.startColor = start
        self.endColor = end
        self._direction = .init(direction.rawValue, 0, 0, 0)
    }
    
    
    public enum Direction: Int32, Equatable, Sendable {
        case horizontal, vertical
    }
}
