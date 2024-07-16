//
//  CanvasKit.swift
//  
//
//  Created by Vaida on 7/17/24.
//


import Metal


/// The global setup.
public enum CanvasKitConfiguration {
    
    /// The default Metal compute device.
    ///
    /// This device is used to make computations and create buffers.
    public static var computeDevice = MTLCreateSystemDefaultDevice()!
    
}
