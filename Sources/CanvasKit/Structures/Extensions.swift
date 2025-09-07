//
//  Extensions.swift
//  CanvasKit
//
//  Created by Vaida on 2025-09-07.
//

import Matrix
import Accelerate


extension Matrix {
    
    /// Generate the Gaussian Blur Kernel.
    ///
    /// - Parameters:
    ///   - size: The radius of the square matrix. The width and height are `2 * radius + 1`
    ///   - distribution: The standard deviation of a univariate. A larger σ means a wider bell.
    ///
    /// - Smaller σ (e.g. 0.3…0.5) yields a tight, crisp blur (narrow bell).
    /// - σ = 0.5 (the default) gives a moderate fall-off: at ±0.5 px from center, the weight is ≈ exp(–0.5²/(2·0.5²)) ≈ 0.61.
    /// - Larger σ (1.0, 2.0, …) produces ever-wider, softer blurs.
    @inlinable
    public static func gaussianBlur(radius: Int, distribution: Float = 0.5) -> Matrix<Float> where Element == Float {
        let size = 2 * radius + 1
        let matrix = Matrix<Float>.repeating(0, height: size, width: size)
        let center: (x: Int, y: Int) = (size / 2, size / 2)
        
        let coefficient = 1 / (2 * Float.pi * distribution * distribution)
        
        func blurValue(of point: (x: Int, y: Int)) -> Float {
            let point: (x: Int, y: Int) = (point.x - center.x, point.y - center.y)
            return coefficient * expf(-1 * Float(point.x * point.x + point.y * point.y) / (2 * distribution * distribution))
        }
        
        for y in 0..<matrix.height {
            for x in 0..<matrix.width {
                matrix[y, x] = blurValue(of: (x, y))
            }
        }
        
        let cumulative = vDSP.sum(UnsafeMutableBufferPointer(start: matrix.pointer, count: matrix.count))
        var buffer = UnsafeMutableBufferPointer(start: matrix.pointer, count: matrix.count)
        vDSP.divide(buffer, cumulative, result: &buffer)
        
        return matrix
    }
    
}
