//
//  Index.swift
//
//
//  Created by Vaida on 7/5/24.
//


/// The index used for finding the elements.
///
/// The first value `y` is the row index, the second value `x` is the column index.
///
/// - Parameters:
///   - y: The index of row, ranges in `0..<` ``height``.
///   - x: The index of row, ranges in `0..<` ``width``.
public struct Index {
    
    let y: Int
    
    let x: Int
    
    
    /// Creates an index.
    public init(y: Int, x: Int) {
        self.y = y
        self.x = x
    }
    
}
