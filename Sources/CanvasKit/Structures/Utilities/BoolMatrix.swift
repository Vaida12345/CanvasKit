//
//  BoolMatrix.swift
//  
//
//  Created by Vaida on 7/7/24.
//


final class BoolMatrix {
    
    let width: Int
    
    let height: Int
    
    private let buffer: UnsafeMutableBufferPointer<UInt8>
    
    
    /// - Parameters:
    ///   - fill: The initial value for each bit.
    init(width: Int, height: Int, fill: Bool) {
        self.width = width
        self.height = height
        
        let size = width * height
        let length = (size / 8) + (size % 8 == 0 ? 0 : 1)
        
        self.buffer = .allocate(capacity: length)
        
        // fill
        if fill {
            var i = 0
            while i < length {
                buffer.initializeElement(at: i, to: UInt8.max)
                i &+= 1
            }
        } else {
            var i = 0
            while i < length {
                buffer.initializeElement(at: i, to: 0)
                i &+= 1
            }
        }
    }
    
    deinit {
        self.buffer.deallocate()
    }
    
    
    subscript(_ index: Index) -> Bool {
        get {
            self[index.y, index.x]
        }
        set {
            self[index.y, index.x] = newValue
        }
    }
    
    subscript(y: Int, x: Int) -> Bool {
        get {
            let initial = y &* width &+ x
            let index = initial / 8
            let offset = initial % 8
            
            return self.buffer[index] & 1 << offset != 0
        }
        set {
            let initial = y &* width &+ x
            let index = initial / 8
            let offset = initial % 8
            
            if newValue {
                self.buffer[index] |= 1 << offset
            } else {
                self.buffer[index] &= ~(1 << offset)
            }
        }
    }
    
}
