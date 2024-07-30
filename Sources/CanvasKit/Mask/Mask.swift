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
    let texture: any MTLTexture
    
    var width: Int {
        self.texture.width
    }
    
    var height: Int {
        self.texture.height
    }
    
    let context: MetalContext?
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    
    public lazy var contents: UnsafeMutableBufferPointer<UInt8> = {
        self.texture.makeBuffer(channelsCount: 1)
    }()
    
#if false
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
                if let row = checkColumn(i: width - index - 1, from: top) {
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
                if let column = checkRow(i: height - index - 1, from: 0, to: width - trailing) {
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
    
#endif
    
    public func makeContext() throws -> CGContext {
        fatalError()
    }
    
    init(texture: any MTLTexture, context: MetalContext) {
        self.texture = texture
        self.context = context
    }
    
    private static func makeTexture(width: Int, height: Int) -> any MTLTexture {
        let descriptor = MTLTextureDescriptor()
        descriptor.height = height
        descriptor.width = width
        descriptor.pixelFormat = .r8Uint
        descriptor.usage = .shaderReadWrite
        descriptor.storageMode = .shared
        
        let device = CanvasKitConfiguration.computeDevice
        return device.makeTexture(descriptor: descriptor)!
    }
    
//    /// Creates a texture full of zero. This would indicate nothing is selected.
//    public convenience init(width: Int, height: Int, context: MetalContext) {
//        
//        
//        self.init(texture: texture, context: context)
//        self.texture.label = "Layer.Texture<(\(width), \(height), 1)>(origin: \(#function))"
//    }
    
    public convenience init(repeating uint8: UInt8 = 0, width: Int, height: Int, context: MetalContext) async throws {
        let texture = Mask.makeTexture(width: width, height: height)
        
        try await MetalFunction(name: "mask_fill_with", bundle: .module)
            .argument(texture: texture)
            .argument(bytes: UInt32(uint8))
            .dispatch(to: context.addJob(), width: width, height: height)
        
        self.init(texture: texture, context: context)
    }
    
    public init(width: Int, height: Int, selecting selection: CGRect, context: MetalContext) throws {
//        let manager = try MetalManager(name: "mask_select", fileWithin: .module, device: CanvasKitConfiguration.computeDevice)
//        manager.setConstant(width)
//        manager.setConstant(UInt(selection.origin.x))
//        manager.setConstant(UInt(selection.origin.y))
//        manager.setConstant(UInt(selection.width))
//        manager.setConstant(UInt(selection.height))
//        
//        let _buffer = try manager.setEmptyBuffer(count: width * height, type: UInt8.self)
//        try manager.perform(width: width, height: height)
        
        fatalError()
    }
    
    /// If returns `true`, there is a mask there, it is selected.
    subscript(_ index: Index) -> UInt8 {
        self[index.y, index.x]
    }
    
    /// If returns `true`, there is a mask there, it is selected.
    subscript(y: Int, x: Int) -> UInt8 {
        precondition(y < self.height && x < self.width)
        return self.contents[y &* width &+ x]
    }
    
}
