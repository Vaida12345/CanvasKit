//
//  GaussianBlur.swift
//  CanvasKit
//
//  Created by Vaida on 2025-09-07.
//

import Testing
import Matrix
import CanvasKit
import MetalManager
import CoreGraphics


@Suite("GaussianBlur")
final class GaussianBlurSuite: TestingSuit {
    
    override func folder() -> String {
        "GaussianBlur"
    }
    
    @Test
    func _3x3() async throws {
        let context = MetalContext()
        
        do {
            var layer = Layer(frame: CGRect(origin: .zero, size: CGSize(width: 5, height: 5)), context: context)
            try await layer.fill(.blue, selection: CGRect(origin: CGPoint(x: 2, y: 2), size: .square(1)))
            layer = try await layer.convolution(kernel: .gaussianBlur(radius: 1))
            
            try await writeAndCompare(
                layer: layer,
                folder: "3x3",
                name: "3_0.5.png"
            )
        }
        
        do {
            var layer = Layer(frame: CGRect(origin: .zero, size: CGSize(width: 5, height: 5)), context: context)
            try await layer.fill(.blue, selection: CGRect(origin: CGPoint(x: 2, y: 2), size: .square(1)))
            layer = try await layer.convolution(kernel: .gaussianBlur(radius: 2))
            
            try await writeAndCompare(
                layer: layer,
                folder: "3x3",
                name: "5_0.5.png"
            )
        }
        
        do {
            var layer = Layer(frame: CGRect(origin: .zero, size: CGSize(width: 5, height: 5)), context: context)
            try await layer.fill(.blue, selection: CGRect(origin: CGPoint(x: 2, y: 2), size: .square(1)))
            layer = try await layer.convolution(kernel: .gaussianBlur(radius: 1, distribution: 1))
            
            try await writeAndCompare(
                layer: layer,
                folder: "3x3",
                name: "3_1.png"
            )
        }
        
        do {
            var layer = Layer(frame: CGRect(origin: .zero, size: CGSize(width: 5, height: 5)), context: context)
            try await layer.fill(.blue, selection: CGRect(origin: CGPoint(x: 2, y: 2), size: .square(1)))
            layer = try await layer.convolution(kernel: .gaussianBlur(radius: 2, distribution: 1))
            
            try await writeAndCompare(
                layer: layer,
                folder: "3x3",
                name: "5_1.png"
            )
        }
    }
    
}
