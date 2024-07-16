//
//  Preview.swift
//  
//
//  Created by Vaida on 7/10/24.
//

import SwiftUI
import Stratum
import AppKit
import GraphicsKit


private func makeSampleLayer() throws -> Layer {
    let canvas = CanvasKit.Canvas(width: 256, height: 256)
    
    try canvas.add(layer: Layer(fill: .white, width: 256, height: 256))
    try canvas.add(layer: Layer(fill: .black, width: 256 - 32 * 2, height: 256 - 32 * 2, origin: CGPoint(x: 32, y: 32)))
    try canvas.add(layer: Layer(fill: .white, width: 256 - 64 * 2, height: 256 - 64 * 2, origin: CGPoint(x: 64, y: 64)))
    
    return try Layer(canvas.render())
}


#Preview {
    let layer = try! makeSampleLayer()
    let canvas = CanvasKit.Canvas(layer: layer)
    
    try! makeCanvas(layer: layer, canvas: canvas)
    
    return try! Image(cgImage: canvas.render())
}


private func makeCanvas(layer: Layer, canvas: CanvasKit.Canvas) throws {
    canvas.layers.remove(at: 0)
    
    let mask = try layer.select(by: .color(.black))
    let copy = try layer.copy(selection: mask)
    try copy.fill(color: .red, selection: copy.select())
    
    try copy.transform(.resize(to: .square(200)))
    
    canvas.add(layer: copy)
    
    let shadow = copy.copy()
    try shadow.fill(color: .black, selection: Mask(repeating: true, width: shadow.width, height: shadow.height))
    try shadow.fill(color: .clear, selection: copy.select().inverse())
    
    try shadow.expand(to: CGRect(x: -100, y: -100, width: copy.width + 200, height: copy.height + 200))
    let kernel = Matrix<Float>.gaussianBlurKernel(size: 81, distribution: 50)
    
    try shadow.apply(.convolution(kernel: kernel, layers: .alpha))
    shadow.origin += CGPoint(x: 10, y: 10)
    
    canvas.add(layer: shadow, at: canvas.layers.firstIndex(of: copy)!)
}
