//
//  Layer.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Foundation
import CoreGraphics


/// An image layer, the direct container to an image buffer.
public final class Layer: LayerProtocol {
    
    internal private(set) var buffer: UnsafeMutableBufferPointer<UInt8>
    
    /// The origin relative to the Canvas.
    ///
    /// - Invariant: the origin is relative to the canvas, which means this value may be modified when the parent canvas changes in size.
    internal private(set) var origin: CGPoint
    
    internal private(set) var width: Int
    
    internal private(set) var height: Int
    
    internal private(set) var deallocator: Data.Deallocator
    
    let colorSpace: CGColorSpace
    
    
    public func makeContext() -> CGContext {
        CGContext(data: self.buffer.baseAddress!, width: self.width, height: self.height, bitsPerComponent: 8, bytesPerRow: 4 * self.width, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    }
    
    func set(buffer: UnsafeMutableBufferPointer<UInt8>, width: Int, height: Int, origin: CGPoint, deallocator: Data.Deallocator) {
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
        assert(width * height * 4 == buffer.count)
        
        self.buffer = buffer
        self.width = width
        self.height = height
        self.origin = origin
        self.deallocator = deallocator
    }
    
    public init(byteNoCopy buffer: UnsafeMutableBufferPointer<UInt8>, origin: CGPoint, width: Int, height: Int, colorSpace: CGColorSpace, deallocator: Data.Deallocator) {
        assert(width * height * 4 == buffer.count)
        self.buffer = buffer
        self.origin = origin
        self.width = width
        self.height = height
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
