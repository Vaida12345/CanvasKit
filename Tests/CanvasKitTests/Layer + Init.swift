//
//  Layer + Init.swift
//  CanvasKit
//
//  Created by Vaida on 7/31/24.
//

import Testing
import Foundation
@testable
import CanvasKit
import Stratum
@testable
import MetalManager


extension Tag {
    @Tag static var layer: Tag
    @Tag static var `init`: Tag
}


@Suite(.tags(.layer, .`init`))
final class Layer_init: TestingSuit {
    
    override func folder() -> String {
        "Layer"
    }
    
    @Test
    func init_from_image() async throws {
        let source = makeSampleCGImage()
        let context = try await MetalContext()
        
        let layer = try await Layer(source, context: context)
        let rendered = try await layer.render()
        
        try await writeAndCompare(
            layer: layer,
            folder: "layer_init",
            name: "init_from_image.png"
        )
        
        assertCGImagesEqual(source, rendered)
        
        let second = try await Layer(source, center: .zero, context: context)
        try await assertCGImagesEqual(second.render(), source)
        #expect(second.origin == -CGPoint(x: source.width / 2, y: source.height / 2))
    }
    
    @Test
    func init_empty() async throws {
        let context = try await MetalContext()
        let layer = Layer(width: 1000, height: 1000, context: context)
        
        try await writeAndCompare(
            layer: layer,
            folder: "layer_init",
            name: "layer_init_empty.png"
        )
    }
    
}
