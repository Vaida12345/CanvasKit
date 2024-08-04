//
//  main.swift
//  
//
//  Created by Vaida on 7/10/24.
//

import Stratum
@testable
import CanvasKit
import AppKit
import MetalManager
import OSLog


let destination = FinderItem.downloadsDirectory.appending(path: "Tests")
try destination.removeIfExists()
try destination.makeDirectory()

await MetalManager.prepareCache()

let focusRect = CGRect(x: 333, y: 376, width: 359, height: 359)
let context = try await MetalContext()

let configuration = NSImage.SymbolConfiguration(pointSize: 359, weight: .regular, scale: .large)
let image = NSImage(systemSymbolName: "shippingbox", accessibilityDescription: nil)!.withSymbolConfiguration(configuration)!.cgImage!

for i in 0..<10 {
    let layer = try await measure("run loop") {
        let canvas = Canvas()
        
        var focusLayer = try await measure("image from layer") {
            try await Layer(image, context: context)
        }
        focusLayer = try await focusLayer.cropping(to: focusLayer.select().boundary())
        focusLayer = try await focusLayer.aspectRatioResize(.fit, in: focusRect)
        let focusSelection = try await focusLayer.select()
        try await focusLayer.fill(.init(red: 94 / 255, green: 168 / 255, blue: 224 / 255, alpha: 1), selection: focusSelection)
        canvas.add(layer: focusLayer)
        
        var shadow = Layer(frame: CGRect(center: focusLayer.frame.center, size: CGSize(width: 400, height: 400)), context: context)
        shadow.origin -= CGPoint(x: 0, y: 0.5)
        
        let expandedFocus = try await focusSelection.expanding(to: CGRect(center: focusSelection.size.center, size: shadow.size)).invert()
        
        try await shadow.fill(PartialColor(red: 1, green: 1, blue: 1, alpha: 43 / 255))
        try await shadow.fill(PartialColor(red: nil, green: nil, blue: nil, alpha: 0), selection: expandedFocus)
        
        shadow = try await shadow.convolution(kernel: Matrix<Float>.gaussianBlurKernel(size: 27, distribution: 21), components: .alpha)
        try await shadow.fill(PartialColor(red: nil, green: nil, blue: nil, alpha: 0), selection: expandedFocus)
        canvas.add(layer: shadow)
        
        var innerShadow = Layer(frame: CGRect(center: focusLayer.frame.center, size: CGSize(width: 400, height: 400)), context: context)
        innerShadow.origin -= CGPoint(x: 0, y: 0.5)
        try await innerShadow.fill(.init(red: 0, green: 0, blue: 0, alpha: 25 / 255))
        try await innerShadow.fill(PartialColor(red: nil, green: nil, blue: nil, alpha: 0), selection: expandedFocus)
        innerShadow = try await innerShadow.convolution(kernel: Matrix<Float>.gaussianBlurKernel(size: 7, distribution: 5), components: .alpha)
        canvas.add(layer: innerShadow)
        
        let layer = try await canvas.makeLayer(width: 1024, height: 1024, context: context)
        try await context.synchronize()
        return layer
    }
    
//    try await Canvas(layer: focusLayer).makeLayer(width: 1024, height: 1024, context: context)
//        .render()
//        .write(to: destination.appending(path: "blend \(i)_focus.heic"))
//    
//    try await Canvas(layer: shadow).makeLayer(width: 1024, height: 1024, context: context)
//        .render()
//        .write(to: destination.appending(path: "blend \(i)_shadow.heic"))
//    
//    try await Canvas(layer: innerShadow).makeLayer(width: 1024, height: 1024, context: context)
//        .render()
//        .write(to: destination.appending(path: "blend \(i)_inner.heic"))
//
    
    try await layer.render().write(to: destination.appending(path: "blend \(i).png"))
}
