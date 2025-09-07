//
//  Layer + Select.swift
//  CanvasKit
//
//  Created by Vaida on 8/3/24.
//

import Testing
import Foundation
@testable
import CanvasKit

@testable
import MetalManager


extension Tag {
    @Tag static var select: Tag
}


@Suite(.tags(.layer, .select))
final class Layer_Select: TestingSuit {
    
    override func folder() -> String {
        "Layer"
    }
    
    @Test
    func select_by_visible() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        
        try await writeAndCompare(
            layer: layer.select(),
            folder: "layer_select",
            name: "select_by_visible.png"
        )
    }
    
    @Test
    func select_by_color() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeSampleCGImage(), context: context)
        let mask = try await layer.select(by: .color(.black))
        let size = layer.size
        
        try await writeAndCompare(
            layer: mask,
            folder: "layer_select",
            name: "select_by_color.png"
        )
        
        do {
            let layer = Layer(frame: CGRect(origin: .zero, size: size), context: context)
            try await layer.fill(.red, selection: mask)
            
            try await writeAndCompare(
                layer: layer,
                folder: "layer_select",
                name: "select_by_color_and_fill.png"
            )
        }
    }
    
    @Test
    func select_by_point() async throws {
        let context = MetalContext()
        let layer = try await Layer(makeDisjointCGImage(), context: context)
        
        try await writeAndCompare(
            layer: layer.select(by: .color(at: CGPoint(x: 5, y: 5), contiguous: false)),
            folder: "layer_select",
            name: "select_by_point_without_contiguous.png"
        )
        
        try await writeAndCompare(
            layer: layer.select(by: .color(at: CGPoint(x: 5, y: 5))),
            folder: "layer_select",
            name: "select_by_point.png"
        )
    }
    
}
