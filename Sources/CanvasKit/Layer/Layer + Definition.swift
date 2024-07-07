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
    
    internal private(set) var buffer: UnsafeMutableBufferPointer<UInt8>
    
    /// The frame relative to the Canvas.
    ///
    /// - Invariant: the origin is relative to the canvas, which means this value may be modified when the parent canvas changes in size.
    ///
    /// - Invariant: same as `CoreGraphics`, the origin is the bottom-left corner.
    internal private(set) var frame: CGRect
    
    internal private(set) var deallocator: Data.Deallocator
    
    let colorSpace: CGColorSpace
    
    
    var width: Int {
        Int(self.frame.width)
    }
    
    var height: Int {
        Int(self.frame.height)
    }
    
    var origin: CGPoint {
        get {
            self.frame.origin
        }
        set {
            self.frame.origin = newValue
        }
    }
    
    var size: CGSize {
        self.frame.size
    }
    
    
    public func makeContext() -> CGContext {
        CGContext(data: self.buffer.baseAddress!, width: Int(self.frame.width), height: Int(self.frame.height), bitsPerComponent: 8, bytesPerRow: 4 * Int(self.frame.width), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    }
    
    /// Returns the color at the given index.
    ///
    /// - Parameters:
    ///   - index: The index of the required color.
    func color(at index: Index) -> Color {
        let index = Int(self.frame.width) * index.y + index.x
        
        let startIndex = index * 4
        
        return Color(red:   buffer[startIndex],
                     green: buffer[startIndex + 1],
                     blue:  buffer[startIndex + 2],
                     alpha: buffer[startIndex + 3]
        )
    }
    
    func set(buffer: UnsafeMutableBufferPointer<UInt8>, frame: CGRect, deallocator: Data.Deallocator) {
        switch self.deallocator {
        case .free:
            self.buffer.deallocate()
        case .none:
            break
        case .custom(let deallocator):
            deallocator(buffer.baseAddress!, buffer.count)
        default:
            fatalError("The deallocator has not been implemented")
        }
        assert(Int(frame.width) * Int(frame.height) * 4 == buffer.count)
        
        self.buffer = buffer
        self.frame = frame
        self.deallocator = deallocator
    }
    
    func set(buffer: UnsafeMutableBufferPointer<UInt8>, width: Int, height: Int, origin: CGPoint, deallocator: Data.Deallocator) {
        self.set(
            buffer: buffer,
            frame: CGRect(origin: origin, size: CGSize(width: width, height: height)),
            deallocator: deallocator
        )
    }
    
    func set(buffer: any MTLBuffer, width: Int, height: Int, origin: CGPoint) {
        self.set(
            buffer: UnsafeMutableBufferPointer(start: buffer.contents().assumingMemoryBound(to: UInt8.self), count: width * height * 4),
            frame: CGRect(origin: origin, size: CGSize(width: width, height: height)),
            deallocator: .none
        )
    }
    
    func set(buffer: any MTLBuffer, frame: CGRect) {
        self.set(
            buffer: UnsafeMutableBufferPointer(start: buffer.contents().assumingMemoryBound(to: UInt8.self), count: width * height * 4),
            frame: frame,
            deallocator: .none
        )
    }
    
    public init(byteNoCopy buffer: UnsafeMutableBufferPointer<UInt8>, origin: CGPoint = .zero, width: Int, height: Int, colorSpace: CGColorSpace, deallocator: Data.Deallocator) {
        assert(width * height * 4 == buffer.count)
        self.buffer = buffer
        self.frame = CGRect(origin: origin, size: CGSize(width: width, height: height))
        self.deallocator = deallocator
        self.colorSpace = colorSpace
    }
    
    public init(byteNoCopy buffer: UnsafeMutableBufferPointer<UInt8>, frame: CGRect, colorSpace: CGColorSpace, deallocator: Data.Deallocator) {
        assert(Int(frame.width) * Int(frame.height) * 4 == buffer.count)
        self.buffer = buffer
        self.frame = frame
        self.deallocator = deallocator
        self.colorSpace = colorSpace
    }
    
    deinit {
        switch deallocator {
        case .free:
            self.buffer.deallocate()
        case .none:
            break
        case .custom(let deallocator):
            deallocator(buffer.baseAddress!, buffer.count)
        default:
            fatalError("The deallocator has not been implemented")
        }
    }
    
}
