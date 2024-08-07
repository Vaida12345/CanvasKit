//
//  Mask.swift
//  CanvasKit
//
//  Created by Vaida on 7/30/24.
//

import Testing
import Foundation
@testable
import CanvasKit
import Stratum
@testable
import MetalManager
import OSLog


extension Tag {
    @Tag static var mask: Tag
}


@Suite(.tags(.mask))
final class MaskSuit: TestingSuit {
    
    override func folder() -> String {
        "Mask"
    }
    
    @Test func mask_init_fill() async throws {
        try await writeAndCompare(
            layer: Mask(repeating: 0, width: 100, height: 100, context: MetalContext()),
            folder: "mask_init_fill",
            name: "mask_fill_zero.png"
        )
        
        try await writeAndCompare(
            layer: Mask(repeating: 1, width: 100, height: 100, context: MetalContext()),
            folder: "mask_init_fill",
            name: "mask_fill_full.png"
        )
        
        try await writeAndCompare(
            layer: Mask(repeating: 0.5, width: 100, height: 100, context: MetalContext()),
            folder: "mask_init_fill",
            name: "mask_fill_half.png"
        )
    }
    
    @Test func mask_init_select() async throws {
        try await writeAndCompare(
            layer: Mask(width: 100, height: 100, selecting: CGRect(origin: .init(x: 25, y: 25), size: .square(50)), context: MetalContext()),
            folder: "mask_init_select",
            name: "mask_with_selection.png"
        )
    }
    
    @Test func mask_isEmpty() async throws {
        let mask = try await Mask(repeating: 255, width: 100, height: 100, context: MetalContext())
        
        let state = try await mask.isEmpty()
        #expect(state.content.contents().assumingMemoryBound(to: Bool.self).pointee == true)
        try await #expect(state.synchronize() == false)
    }
    
    @Test func mask_boundary() async throws {
        let selection = CGRect(origin: .init(x: 2, y: 2), size: .square(6))
        let mask = try await Mask(width: 10, height: 10, selecting: selection, context: MetalContext())
        let boundary = try await mask.boundary()
        
        #expect(boundary == selection)
    }
    
    @Test func mask_inverse() async throws {
        let mask = try await Mask(width: 100, height: 100, selecting: CGRect(origin: .init(x: 25, y: 25), size: .square(50)), context: MetalContext())
        let invert = try await mask.invert()
        
        try await invert.context.synchronize()
        
        for (lhs, rhs) in try zip(mask.texture.makeBuffer(channelsCount: 1), invert.texture.makeBuffer(channelsCount: 1)) {
            try #require(lhs + rhs == .max)
        }
    }
    
    @Test func mask_expand() async throws {
        let logger = Logger(subsystem: "CanvasKit", category: "Testing")
        
        let context = measure("make context") {
            MetalContext()
        }
        
        let date = Date()
        let mask = try await Mask(repeating: 255, width: 100, height: 100, context: context)
        let newMask = try await mask.expanding(to: CGRect(origin: .zero, size: .square(200)))
        
        let expandedMask = try await mask.expanding(to: CGRect(origin: -CGPoint(x: 50, y: 50), size: .square(200)))
        let shrinkMask = try await expandedMask.cropping(to: CGRect(origin: CGPoint(x: 25, y: 25), size: .square(100)))
        logger.info("mask_expand, Prepare textures took \(date.distanceToNow())")
        
        try await writeAndCompare(
            layer: newMask,
            folder: "mask_expand",
            name: "expanded_mask.png"
        )
        
        try await writeAndCompare(
            layer: expandedMask,
            folder: "mask_expand",
            name: "expanded_mask_expand.png"
        )
        
        try await writeAndCompare(
            layer: shrinkMask,
            folder: "mask_expand",
            name: "expanded_mask_shrink.png"
        )
    }
    
}

