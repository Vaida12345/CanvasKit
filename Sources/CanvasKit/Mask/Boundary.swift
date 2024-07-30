//
//  Boundary.swift
//  CanvasKit
//
//  Created by Vaida on 7/30/24.
//

import Metal
import MetalManager


extension Mask {
    
    public actor Boundary {
        
        private let context: MetalContext
        
        internal var rows: any MTLBuffer
        internal var columns: any MTLBuffer
        
        private let rowsCount: Int
        private let columnsCount: Int
        
        
        /// Obtain the CGRect out of the boundary.
        ///
        /// - Important: Doing so would dispatch the GPU operations. This is extremely costly. Avoid this when possible.
        ///
        /// - Tip: You can use this structure in stead of CGRect in most cases.
        public func makeCGRect() async throws -> CGRect {
            try await context.synchronize()
            
            let rows = UnsafeMutableBufferPointer(start: self.rows.contents().assumingMemoryBound(to: Bool.self), count: rowsCount)
            let columns = UnsafeMutableBufferPointer(start: self.columns.contents().assumingMemoryBound(to: Bool.self), count: columnsCount)
            
            let x_start = columns.firstIndex(of: true) ?? 0
            let x_end   = columns.lastIndex(of: true)  ?? 0
            
            let y_start = rows.firstIndex(of: true) ?? 0
            let y_end   = rows.lastIndex(of: true)  ?? 0
            
            return CGRect(x: x_start, y: y_start, width: x_end - x_start + 1, height: y_end - y_start + 1)
        }
        
        
        internal init(context: MetalContext, rows: any MTLBuffer, columns: any MTLBuffer, rowsCount: Int, columnsCount: Int) {
            self.context = context
            self.rows = rows
            self.columns = columns
            self.rowsCount = rowsCount
            self.columnsCount = columnsCount
        }
        
    }
    
}
