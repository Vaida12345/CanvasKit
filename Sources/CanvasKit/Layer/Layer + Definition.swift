//
//  Layer.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Foundation
import CoreGraphics
import Metal


/// An image layer, the direct container to an image buffer.
public final class Layer: LayerProtocol {
    
    internal private(set) var buffer: any MTLBuffer
    
    /// The frame relative to the Canvas.
    ///
    /// - Invariant: the origin is relative to the canvas, which means this value may be modified when the parent canvas changes in size.
    ///
    /// - Invariant: this implementation does not use `CoreGraphics` for rendering, hence the origin was chosen to be top-left corner.
    public private(set) var frame: CGRect
    
    let colorSpace: CGColorSpace
    
    
    public var width: Int {
        Int(self.frame.width)
    }
    
    public var height: Int {
        Int(self.frame.height)
    }
    
    public var origin: CGPoint {
        get {
            self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
    
    public var size: CGSize {
        self.frame.size
    }
    
    
    public func makeContext() -> CGContext {
        CGContext(data: self.buffer.contents(), width: Int(self.frame.width), height: Int(self.frame.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(self.frame.width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    }
    
    /// Returns the color at the given index.
    ///
    /// - Parameters:
    ///   - index: The index of the required color.
    ///
    /// - Important: This is a relatively heavy operation.
    func color(at index: Index) -> Color {
        let index = Int(self.frame.width) * index.y + index.x
        
        let buffer = UnsafeMutableBufferPointer(start: self.buffer.contents().assumingMemoryBound(to: UInt8.self), count: self.width * self.height * 4)
        
        let startIndex = index * 4
        
        return Color(red:   buffer[startIndex],
                     green: buffer[startIndex + 1],
                     blue:  buffer[startIndex + 2],
                     alpha: buffer[startIndex + 3]
        )
    }
    
    func set(buffer: any MTLBuffer, frame: CGRect) {
        assert(Int(frame.width) * Int(frame.height) * 4 * MemoryLayout<UInt8>.stride == buffer.length)
        
        self.buffer = buffer
        self.frame = frame
    }
    
    func set(buffer: any MTLBuffer, width: Int, height: Int, origin: CGPoint) {
        self.set(
            buffer: buffer,
            frame: CGRect(origin: origin, size: CGSize(width: width, height: height))
        )
    }
    
    public init(buffer: any MTLBuffer, origin: CGPoint = .zero, width: Int, height: Int, colorSpace: CGColorSpace) {
        assert(width * height * 4 * MemoryLayout<UInt8>.stride == buffer.length)
        self.buffer = buffer
        self.frame = CGRect(origin: origin, size: CGSize(width: width, height: height))
        self.colorSpace = colorSpace
    }
    
    public init(buffer: any MTLBuffer, frame: CGRect, colorSpace: CGColorSpace) {
        assert(Int(frame.width) * Int(frame.height) * 4 * MemoryLayout<UInt8>.stride == buffer.length)
        self.buffer = buffer
        self.frame = frame
        self.colorSpace = colorSpace
    }
    
}
