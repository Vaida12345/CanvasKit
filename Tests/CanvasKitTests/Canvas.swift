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
        let context = try await MetalContext()
        
        let red_layer = Layer(width: 100, height: 100, context: context)
        try await red_layer.fill(.red)
        
        let green_layer = Layer(width: 100, height: 100, context: context)
        try await green_layer.fill(.green)
        
        let canvas = Canvas(layers: [red_layer, green_layer])
        let texture = try await canvas.makeTexture(width: 100, height: 100, context: context)
        
        try await context.synchronize()
        
        try await writeAndCompare(
            texture: texture,
            folder: "canvas_blend",
            name: "blend_1.png"
        )
    }
    
    @Test
    func test_blend_2() async throws {
        let context = try await MetalContext()
        
        let red_layer = Layer(width: 100, height: 100, context: context)
        try await red_layer.fill(.red.opacity(0.5))
        
        let green_layer = Layer(width: 100, height: 100, context: context)
        try await green_layer.fill(.green.opacity(0.5))
        
        let canvas = Canvas(layers: [red_layer, green_layer])
        let texture = try await canvas.makeTexture(width: 100, height: 100, context: context)
        
        try await context.synchronize()
        
        try await writeAndCompare(
            texture: texture,
            folder: "canvas_blend",
            name: "blend_2.png"
        )
    }
    
}
