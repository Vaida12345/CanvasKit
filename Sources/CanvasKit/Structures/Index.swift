//
//  Index.swift
//
//
//  Created by Vaida on 7/5/24.
//

import Stratum
import CoreGraphics


/// The index used for finding the elements.
///
/// The first value `y` is the row index, the second value `x` is the column index.
///
/// - Parameters:
///   - y: The index of row, ranges in `0..<` ``height``.
///   - x: The index of row, ranges in `0..<` ``width``.
public struct Index {
    
    public let y: Int
    
    public let x: Int
    
    
    /// Creates an index.
    public init(y: Int, x: Int) {
        self.y = y
        self.x = x
    }
    
    /// Creates an index.
    public init(_ point: CGPoint) {
        let x = Int(point.x.rounded(.toNearestOrAwayFromZero))
        let y = Int(point.y.rounded(.toNearestOrAwayFromZero))
        
        self.init(y: y, x: x)
    }
    
    func flatten(width: Int) -> Int {
        self.y &* width &+ self.x
    }
    
    /// Returns the checked moved index.
    public func move(down: Int, right: Int, width: Int, height: Int) -> Index? {
        let x = self.x &+ right
        let y = self.y &+ down
        
        if x >= 0 && y >= 0 && x < width && y < height {
            return Index(y: y, x: x)
        } else {
            return nil
        }
    }
    
    func adjacent(width: Int, height: Int) -> [Index] {
        var result: [Index] = []
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]  // Right, Down, Left, Up
        for direction in directions {
            if let new = self.move(down: direction.0, right: direction.1, width: width, height: height) {
                result.append(new)
            }
        }
        return result
    }
    
    
    public enum IndexingError: GenericError {
        case indexOutOfRange
        
        public var title: String {
            "Indexing Error"
        }
        
        public var message: String {
            "Index out of range."
        }
    }
    
}
