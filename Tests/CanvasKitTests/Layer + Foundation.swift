//
//  Layer + Foundation.swift
//  CanvasKit
//
//  Created by Vaida on 8/2/24.
//


import Testing
import Foundation
@testable
import CanvasKit
import Stratum
@testable
import MetalManager


extension Tag {
    @Tag static var foundation: Tag
}


@Suite(.tags(.layer, .foundation))
final class Layer_Foundation: TestingSuit {
    
    override func folder() -> String {
        "Layer"
    }
    
    @Test
    func layer_copy() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        
        #expect(try await layer.isBitwiseEqual(to: layer.copy()))
    }
    
    @Test
    func layer_copy_with_selection() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        let mask = try await Mask(width: layer.width, height: layer.height, selecting: CGRect(x: 2, y: 2, width: 10, height: 10), context: context)
        let copy = try await layer.copy(selection: mask)
        try await layer.fill(.clear, selection: mask.invert())
        
        #expect(try await layer.isBitwiseEqual(to: copy))
    }
    
    @Test
    func layer_expand() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        
        let expandedMask = try await layer.expanding(to: CGRect(origin: -CGPoint(x: 10, y: 10), size: .square(50)))
        
        try await writeAndCompare(
            layer: expandedMask,
            folder: "layer_expand",
            name: "expanded_layer_expand.png"
        )
        
        try await writeAndCompare(
            layer: expandedMask.cropping(to: CGRect(origin: CGPoint(x: 5, y: 5), size: .square(20))),
            folder: "layer_expand",
            name: "expanded_layer_shrink.png"
        )
    }
    
    @Test
    func layer_invert() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        
        try await layer.invert()
        
        try await writeAndCompare(
            layer: layer,
            folder: "layer_invert",
            name: "inverted_layer.png"
        )
    }
    
    @Test
    func layer_subtract() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        try await layer.fill(.white.opacity(nil))
        
        let other = Layer(width: layer.width, height: layer.height, context: context)
        try await other.fill(.white)
        
        try await other -= layer
        
        try await writeAndCompare(
            layer: other,
            folder: "layer_subtract",
            name: "layer_subtract.png"
        )
    }
    
    @Test
    func layer_conv() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        try await layer.fill(.white.opacity(nil))
        
        let conv_1x1 = try await layer.convolution(kernel: .gaussianBlurKernel(size: 1, distribution: 1))
        let conv_3x3 = try await layer.convolution(kernel: .gaussianBlurKernel(size: 3, distribution: 3))
        
        try await writeAndCompare(
            layer: conv_1x1,
            folder: "layer_conv",
            name: "conv_1x1.png"
        )
        
        try await writeAndCompare(
            layer: conv_3x3,
            folder: "layer_conv",
            name: "conv_3x3.png"
        )
    }
    
    @Test
    func layer_fill() async throws {
        let context = MetalContext()
        
        let simple_layer = try await Layer(fill: .green, width: 193, height: 193, context: context)
        try await simple_layer.fill(.red, selection: CGRect(x: 1, y: 1, width: 191, height: 191))
        
        try await writeAndCompare(
            layer: simple_layer,
            folder: "layer_fill",
            name: "layer_fill.png"
        )
        
    }
    
    @Test
    func layer_resize() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        try await layer.fill(.white.opacity(nil))
        
        let simple_layer = try await Layer(fill: .green, width: 193, height: 193, context: context)
        try await simple_layer.fill(.red, selection: CGRect(x: 1, y: 1, width: 191, height: 191))
        
        let resize_simple_large = try await simple_layer.resized(to: CGSize(width: 193 * 2, height: 193))
        let resize_simple_small = try await simple_layer.resized(to: CGSize(width: 20, height: 20))
        
        let resize_large = try await layer.resized(to: CGSize(width: 400, height: 200))
        let resize_small = try await layer.resized(to: CGSize(width: 20, height: 20))
        
        try await writeAndCompare(
            layer: resize_simple_large,
            folder: "layer_resize",
            name: "resize_simple_large.png"
        )
        
        try await writeAndCompare(
            layer: resize_simple_small,
            folder: "layer_resize",
            name: "resize_simple_small.png"
        )
        
        try await writeAndCompare(
            layer: resize_large,
            folder: "layer_resize",
            name: "resize_large.png"
        )
        
        try await writeAndCompare(
            layer: resize_small,
            folder: "layer_resize",
            name: "resize_small.png"
        )
    }
    
    @Test
    func layer_shifted() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        
        try await writeAndCompare(
            layer: try await layer.shifted(x: 5, y: 5),
            folder: "layer_shifted",
            name: "layer_shifted.png"
        )
        
        try await writeAndCompare(
            layer: try await layer.shifted(x: 5 as Float, y: 5),
            folder: "layer_shifted",
            name: "layer_shifted_float.png"
        )
    }
    
}
