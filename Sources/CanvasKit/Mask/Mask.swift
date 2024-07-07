//
//  Mask.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Foundation
import MetalManager
import CoreGraphics


/// An immutable mask.
public final class Mask: LayerProtocol {
    
    /// Each pixel would take one byte. It is a waste, but could avoid metal data racing.
    let buffer: UnsafeMutableBufferPointer<Bool>
    
    let size: CGSize
    
    let deallocator: Data.Deallocator
    
    
    var width: Int {
        Int(self.size.width)
    }
    
    var height: Int {
        Int(self.size.height)
    }
    
    
    /// Determines if the mask is an empty mask.
    public lazy var isEmpty: Bool = {
        var y = 0
        while y < self.height {
            var x = 0
            while x < self.width {
                if self[y ,x] {
                    return false
                }
                
                x &+= 1
            }
            y &+= 1
        }
        
        return true
    }()
    
    /// The boundary of the mask.
    ///
    /// For a mask of
    /// ```
    /// 0 0 0 0
    /// 0 1 1 0
    /// 0 1 1 0
    /// 0 0 0 0
    /// ```
    /// the boundary is `CGRect(x: 1, y: 1, width: 2, height: 2)`.
    public lazy var boundary: CGRect = {
        
        func checkRow(i: Int, from: Int = 0, to: Int = width) -> Int? {
            var index = from
            while index < to {
                guard !self[Index(y: i, x: index)] else { return index }
                index &+= 1
            }
            return nil
        }
        func checkColumn(i: Int, from: Int = 0, to: Int = height) -> Int? {
            var index = from
            while index < to {
                guard !self[Index(y: index, x: i)] else { return index }
                index &+= 1
            }
            return nil
        }
        
        var top = 0
        var bottom = 0
        var leading = 0
        var trailing = 0
        
        // check from up
        if true {
            var index = 0
            while index < height {
                if let column = checkRow(i: index) {
                    break
                }
                
                index &+= 1
                top = index
            }
            
            if index == height {
                return CGRect(x: 0, y: 0, width: width, height: height)
            }
        }
        
        // check trailing
        if true {
            var index = 0
            while index < width - leading {
                if let row = checkColumn(i: index, from: top) {
                    break
                }
                
                index &+= 1
                trailing = index
            }
        }
        
        // check bottom
        if true {
            var index = 0
            while index < height - top {
                if let column = checkRow(i: index, from: 0, to: width - trailing) {
                    break
                }
                
                index &+= 1
                bottom = index
            }
        }
        
        // check leading
        if true {
            var index = 0
            while index < width {
                if let row = checkColumn(i: index, from: top, to: height - bottom) {
                    break
                }
                
                index &+= 1
                leading = index
            }
        }
        
        return CGRect(x: leading, y: top, width: self.width - trailing - leading, height: self.height - bottom - top)
    }()
    
    
    public func inverse() throws -> Mask {
        let manager = try MetalManager(name: "mask_reverse", fileWithin: .module)
        try manager.setBuffer(self.buffer)
        let result = try manager.setEmptyBuffer(count: self.buffer.count, type: Bool.self)
        try manager.perform(width: self.buffer.count)
        return Mask(BytesNoCopy: UnsafeMutableBufferPointer(start: result.contents().assumingMemoryBound(to: Bool.self), count: buffer.count), size: self.size, deallocator: .none)
    }
    
    public func makeContext() throws -> CGContext {
        let manager = try MetalManager(name: "mask_render", fileWithin: .module)
        manager.setConstant(self.width)
        let result = try manager.setEmptyBuffer(count: self.width * self.height * 4, type: UInt8.self)
        try manager.setBuffer(self.buffer)
        try manager.perform(width: self.width, height: self.height)
        
        return CGContext(data: result.contents(), width: self.width, height: self.height, bitsPerComponent: 8, bytesPerRow: 4 * self.width, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    }
    
    
    init(BytesNoCopy buffer: UnsafeMutableBufferPointer<Bool>, size: CGSize, deallocator: Data.Deallocator) {
        self.buffer = buffer
        self.size = size
        self.deallocator = deallocator
    }
    
    init(coping buffer: UnsafeMutableBufferPointer<Bool>, size: CGSize) {
        let length = Int(size.width) * Int(size.height)
        self.buffer = .allocate(capacity: length)
        buffer.copy(to: self.buffer.baseAddress!, count: length)
        
        self.size = size
        self.deallocator = .free
    }
    
    init(repeating bool: Bool, width: Int, height: Int) {
        self.buffer = .allocate(capacity: width * height)
        self.buffer.initialize(repeating: bool)
        self.size = CGSize(width: width, height: height)
        self.deallocator = .free
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
    
    /// If returns `true`, there is a mask there, it is selected.
    subscript(_ index: Index) -> Bool {
        self[index.y, index.x]
    }
    
    /// If returns `true`, there is a mask there, it is selected.
    subscript(y: Int, x: Int) -> Bool {
        buffer[y &* width &+ x]
    }
    
}
