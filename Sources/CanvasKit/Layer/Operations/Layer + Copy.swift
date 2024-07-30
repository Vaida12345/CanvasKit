//
//  Layer + Copy.swift
//  
//
//  Created by Vaida on 7/7/24.
//


#if false
extension Layer {
    
    /// Copy the layer.
    public func copy() -> Layer {
        Layer(
            buffer: CanvasKitConfiguration.computeDevice.makeBuffer(bytes: self.buffer.contents(), length: self.width * self.height * 4 * MemoryLayout<UInt8>.stride, options: .storageModeShared)!,
            frame: self.frame,
            colorSpace: self.colorSpace
        )
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
#endif
