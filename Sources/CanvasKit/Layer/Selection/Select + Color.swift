//
//  Select + Color.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import CoreGraphics
import MetalManager
import Metal
import Stratum


public struct SelectByColor: SelectionCriteria {
    
    let color: Color
    
    let tolerance: UInt8
    
    
    public func select(layer: Layer) throws -> Mask {
        let manager = try MetalManager(name: "selectByColor", fileWithin: .module)
        
        manager.setConstant(layer.width)
        manager.setConstant(color.red)
        manager.setConstant(color.green)
        manager.setConstant(color.blue)
        manager.setConstant(tolerance)
        
        let maskLength = (layer.width * layer.height)
        
        try manager.setBuffer(layer.buffer)
        let maskBuffer = try manager.setEmptyBuffer(count: maskLength, type: Bool.self)
        
        try manager.perform(gridSize: MTLSize(width: layer.width, height: layer.height, depth: 1))
        
        let buffer = UnsafeMutableBufferPointer(start: maskBuffer.contents().bindMemory(to: Bool.self, capacity: maskLength), count: maskLength)
        return Mask(BytesNoCopy: buffer, size: layer.frame.size, deallocator: .none)
    }
    
}


public extension SelectionCriteria where Self == SelectByColor {
    
    static func color(_ color: Color, tolerance: UInt8 = 0) -> SelectByColor {
        SelectByColor(color: color, tolerance: tolerance)
    }
    
}
