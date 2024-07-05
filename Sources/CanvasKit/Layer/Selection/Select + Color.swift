//
//  Select + Color.swift
//  
//
//  Created by Vaida on 7/5/24.
//

import CoreGraphics
import MetalManager
import Metal


public struct SelectByColor: SelectionCriteria {
    
    let color: Color
    
    let tolerance: UInt8
    
    let contagiousFrom: CGPoint?
    
    
    
    public func select(layer: Layer) throws -> Mask {
        let manager = try MetalManager(name: "selectByColor", fileWithin: .module)
        
        manager.setConstant(layer.width)
        manager.setConstant(color.red)
        manager.setConstant(color.green)
        manager.setConstant(color.blue)
        manager.setConstant(tolerance)
        
        let maskLength = (layer.width * layer.height)
        
        try manager.setBuffer(layer.buffer)
        let mask = try manager.setEmptyBuffer(count: maskLength, type: UInt8.self)
        
        try manager.perform(gridSize: MTLSize(width: layer.width, height: layer.height, depth: 1))
        
        let buffer = mask.contents().bindMemory(to: Bool.self, capacity: maskLength)
        
        if let contagiousFrom {
            fatalError("Not yet implemented")
        }
        
        return Mask(BytesNoCopy: UnsafeMutableBufferPointer(start: buffer, count: maskLength), width: layer.width, height: layer.height, deallocator: .none)
    }
    
}


extension SelectionCriteria where Self == SelectByColor {
    
    public static func color(_ color: Color, tolerance: UInt8 = 0, contagiousFrom: CGPoint? = nil) -> SelectByColor {
        SelectByColor(color: color, tolerance: tolerance, contagiousFrom: contagiousFrom)
    }
    
}
