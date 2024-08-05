//
//  Canvas.swift
//  CanvasKit
//
//  Created by Vaida on 8/3/24.
//

import Testing
import Foundation
@testable
import CanvasKit
import Stratum
@testable
import MetalManager
import AppKit


extension Tag {
    @Tag static var canvas: Tag
}


@Suite(.tags(.canvas))
final class Canvas_Tests: TestingSuit {
    
    override func folder() -> String {
        "Canvas"
    }
    
    @Test
    func test_blend_1() async throws {
        let context = MetalContext()
        
        let red_layer = Layer(width: 100, height: 100, context: context)
        try await red_layer.fill(.red)
        
        let green_layer = Layer(width: 100, height: 100, context: context)
        try await green_layer.fill(.green)
        
        let canvas = Canvas(layers: [red_layer, green_layer])
        let layer = try await canvas.makeLayer(width: 100, height: 100, context: context)
        
        try await context.synchronize()
        
        try await writeAndCompare(
            layer: layer,
            folder: "canvas_blend",
            name: "blend_1.png"
        )
    }
    
    @Test
    func test_blend_2() async throws {
        let context = MetalContext()
        
        let red_layer = Layer(width: 100, height: 100, context: context)
        try await red_layer.fill(.red.opacity(0.5))
        
        let green_layer = Layer(width: 100, height: 100, context: context)
        try await green_layer.fill(.green.opacity(0.5))
        
        let canvas = Canvas(layers: [red_layer, green_layer])
        let layer = try await canvas.makeLayer(width: 100, height: 100, context: context)
        
        try await context.synchronize()
        
        try await writeAndCompare(
            layer: layer,
            folder: "canvas_blend",
            name: "blend_2.png"
        )
    }
    
    @Test
    func test_advanced_blend_1() async throws {
        let focusRect = CGRect(x: 333, y: 376, width: 359, height: 359)
        let context = MetalContext()
        
        let canvas = Canvas()
        
        let configuration = NSImage.SymbolConfiguration(pointSize: 359, weight: .regular, scale: .large)
        let image = NSImage(systemSymbolName: "shippingbox", accessibilityDescription: nil)!.withSymbolConfiguration(configuration)!.cgImage!
        
        var focusLayer = try await Layer(image, context: context)
        focusLayer = try await focusLayer.cropping(to: focusLayer.select().boundary())
        
        focusLayer = try await focusLayer.aspectRatioResize(.fit, in: focusRect)
        let focusSelection = try await focusLayer.select()
        try await focusLayer.fill(.init(red: 94 / 255, green: 168 / 255, blue: 224 / 255, alpha: 1), selection: focusSelection)
        canvas.add(layer: focusLayer)
        
        var shadow = Layer(frame: CGRect(center: focusLayer.frame.center, size: CGSize(width: 400, height: 400)), context: context)
        try await shadow.fill(PartialColor(red: 1, green: 1, blue: 1, alpha: 43 / 255))
        try await shadow.fill(PartialColor(red: nil, green: nil, blue: nil, alpha: 0), selection: focusSelection.expanding(to: CGRect(center: focusSelection.size.center, size: shadow.size)).invert())
        
        shadow = try await shadow.convolution(kernel: Matrix<Float>.gaussianBlurKernel(size: 27, distribution: 21), components: .alpha)
        canvas.add(layer: shadow)
        
        let layer = try await canvas.makeLayer(width: 1024, height: 1024, context: context)
        
        try await writeAndCompare(
            layer: layer,
            folder: "canvas_blend",
            name: "advanced_blend_1.png"
        )
    }
    
    
    @Test
    func test_advanced_blend_2() async throws {
        let focusRect = CGRect(x: 333, y: 376, width: 359, height: 359)
        let context = MetalContext()
        
        let canvas = Canvas()
        
        let configuration = NSImage.SymbolConfiguration(pointSize: 359, weight: .regular, scale: .large)
        let image = NSImage(systemSymbolName: "shippingbox", accessibilityDescription: nil)!.withSymbolConfiguration(configuration)!.cgImage!
        
        var focusLayer = try await Layer(image, context: context)
        focusLayer = try await focusLayer.cropping(to: focusLayer.select().boundary())
        focusLayer = try await focusLayer.aspectRatioResize(.fit, in: focusRect)
        let focusSelection = try await focusLayer.select()
        try await focusLayer.fill(.init(red: 94 / 255, green: 168 / 255, blue: 224 / 255, alpha: 1), selection: focusSelection)
        canvas.add(layer: focusLayer)
        
        var shadow = Layer(frame: CGRect(center: focusLayer.frame.center, size: CGSize(width: 400, height: 400)), context: context)
        shadow.origin -= CGPoint(x: 0, y: 0.5)
        try await shadow.fill(PartialColor(red: 1, green: 1, blue: 1, alpha: 43 / 255))
        try await shadow.fill(PartialColor(red: nil, green: nil, blue: nil, alpha: 0), selection: focusSelection.expanding(to: CGRect(center: focusSelection.size.center, size: shadow.size)).invert())
        
        shadow = try await shadow.convolution(kernel: Matrix<Float>.gaussianBlurKernel(size: 27, distribution: 21), components: .alpha)
        try await shadow.fill(PartialColor(red: nil, green: nil, blue: nil, alpha: 0), selection: focusSelection.expanding(to: CGRect(center: focusSelection.size.center, size: CGSize(width: 400, height: 400))))
        canvas.add(layer: shadow)
        
        let layer = try await canvas.makeLayer(width: 1024, height: 1024, context: context)
        
        try await writeAndCompare(
            layer: layer,
            folder: "canvas_blend",
            name: "advanced_blend_2.png"
        )
    }
    
}
