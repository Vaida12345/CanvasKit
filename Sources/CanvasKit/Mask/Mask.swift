//
//  Mask.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import Metal
import Foundation
import MetalManager
import CoreGraphics


/// An immutable mask.
public final class Mask: LayerProtocol {
    
    /// Each pixel would take one byte. It is a waste, but could avoid metal data racing.
    let buffer: any MTLBuffer
    
    public let size: CGSize
    
    public let count: Int
    
    
    var width: Int {
        Int(self.size.width)
    }
    
    var height: Int {
        Int(self.size.height)
    }
    
    
    public lazy var contents: UnsafeMutableBufferPointer<Bool> = {
        UnsafeMutableBufferPointer(start: self.buffer.contents().assumingMemoryBound(to: Bool.self), count: self.buffer.length / MemoryLayout<Bool>.stride)
    }()
    
    
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
        let manager = try MetalManager(name: "mask_inverse", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        try manager.setBuffer(self.buffer)
        let result = try manager.setEmptyBuffer(count: self.count, type: Bool.self)
        try manager.perform(width: self.count)
        return Mask(buffer: result, size: self.size)
    }
    
    public func makeContext() throws -> CGContext {
        let manager = try MetalManager(name: "mask_render", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        manager.setConstant(self.width)
        let result = try manager.setEmptyBuffer(count: self.width * self.height * 4, type: UInt8.self)
        try manager.setBuffer(self.buffer)
        try manager.perform(width: self.width, height: self.height)
        
        return CGContext(data: result.contents(), width: self.width, height: self.height, bitsPerComponent: 8, bytesPerRow: 4 * self.width, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    }
    
    
    init(buffer: any MTLBuffer, size: CGSize) {
        self.buffer = buffer
        self.size = size
        self.count = Int(size.width) * Int(size.height)
    }
    
    init(repeating bool: Bool, width: Int, height: Int) throws {
        let manager = try MetalManager(name: "mask_repeat", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        manager.setConstant(bool)
        let _buffer = try manager.setEmptyBuffer(count: width * height, type: Bool.self)
        
        try manager.perform(width: width * height, height: 1)
        
        self.count = width * height
        self.buffer = _buffer
        self.size = CGSize(width: width, height: height)
        
        self.buffer.label = "Mask.buffer<(\(width), \(height))>(origin: \(#function))"
    }
    
    init(width: Int, height: Int, selecting selection: CGRect) throws {
        let manager = try MetalManager(name: "mask_select", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
        manager.setConstant(width)
        manager.setConstant(UInt(selection.origin.x))
        manager.setConstant(UInt(selection.origin.y))
        manager.setConstant(UInt(selection.width))
        manager.setConstant(UInt(selection.height))
        
        let _buffer = try manager.setEmptyBuffer(count: width * height, type: UInt8.self)
        try manager.perform(width: width, height: height)
        
        self.count = width * height
        self.buffer = _buffer
        self.size = CGSize(width: width, height: height)
    }
    
    /// If returns `true`, there is a mask there, it is selected.
    subscript(_ index: Index) -> Bool {
        self[index.y, index.x]
    }
    
    /// If returns `true`, there is a mask there, it is selected.
    subscript(y: Int, x: Int) -> Bool {
        self.contents[y &* width &+ x]
    }
    
}
