//
//  Layer + Copy.swift
//  
//
//  Created by Vaida on 7/7/24.
//


extension Layer {
    
    /// Copy the layer.
    public func copy()-> Layer {
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: self.buffer.count)
        self.buffer.copy(to: buffer.baseAddress!, count: self.buffer.count)
        return Layer(byteNoCopy: buffer, frame: self.frame, colorSpace: self.colorSpace, deallocator: .free)
    }
    
    /// Copy the layer.
    ///
    /// - Parameters:
    ///   - selection: If provided, only the selected region will be copied.
    public func copy(selection: Mask) throws -> Layer {
        let copy = self.copy()
        try copy.delete(selection: selection.inverse())
        return copy
    }
    
}
