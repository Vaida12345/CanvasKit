//
//  Preview.swift
//  
//
//  Created by Vaida on 7/10/24.
//

import SwiftUI
import Stratum
import AppKit

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
    
    let context = copy.makeContext()
    context.data
//    context.setShadow(offset: CGSize(width: 10, height: 10), blur: 100, color: .black)
    
//    let image = try copy.render()
//    
//    let width = copy.width
//    let height = copy.height
//    
//    let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: width * height * 4)
//    let context = CGContext(data: buffer.baseAddress!, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: layer.colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
//    context.setShadow(offset: CGSize(width: 5, height: -5), blur: 10, color: .black)
//    
//    context.draw(image, in: copy.frame)
//    
//    copy.set(
//        buffer: buffer,
//        width: width,
//        height: height,
//        origin: CGRect(center: layer.frame.center, size: layer.size).origin,
//        deallocator: .free
//    )
    
    canvas.add(layer: copy)
}
