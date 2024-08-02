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
        let context = try await MetalContext()
        let layer = try Layer(makeSampleCGImage(), context: context)
        
        #expect(try await layer.isBitwiseEqual(to: layer.copy()))
    }
    
    @Test
    func layer_copy_with_selection() async throws {
        let context = try await MetalContext()
        let layer = try Layer(makeSampleCGImage(), context: context)
        let mask = try await Mask(width: layer.width, height: layer.height, selecting: CGRect(x: 2, y: 2, width: 10, height: 10), context: context)
        let copy = try await layer.copy(selection: mask)
        try await layer.fill(PartialColor(red: 0, green: 0, blue: 0, alpha: 0), mask: mask.invert())
        
        #expect(try await layer.isBitwiseEqual(to: copy))
    }
    
}
