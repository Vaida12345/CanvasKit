//
//  CanvasKit.swift
//  
//
//  Created by Vaida on 7/17/24.
//


import Metal
import MetalManager


/// The global setup.
public enum CanvasKitConfiguration {
    
    /// The default Metal compute device.
    ///
    /// This device is used to make computations and create buffers.
    nonisolated(unsafe) public static var computeDevice: any MTLDevice {
        get {
            MetalManager.computeDevice
        }
        set {
            MetalManager.computeDevice = newValue
        }
    }
    
}
