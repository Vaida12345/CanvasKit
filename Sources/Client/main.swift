//
//  main.swift
//  
//
//  Created by Vaida on 7/10/24.
//

import SwiftUI
import Stratum
@testable
import CanvasKit
import AppKit


private func makeSampleLayer() throws -> Layer {
    let canvas = CanvasKit.Canvas(width: 256, height: 256)
    
    try canvas.add(layer: Layer(fill: .white, width: 256, height: 256))
    try canvas.add(layer: Layer(fill: .black, width: 256 - 32 * 2, height: 256 - 32 * 2, origin: CGPoint(x: 32, y: 32)))
    try canvas.add(layer: Layer(fill: .white, width: 256 - 64 * 2, height: 256 - 64 * 2, origin: CGPoint(x: 64, y: 64)))
    
    try canvas.render().write(to: FinderItem.downloadsDirectory.appending(path: "file 3.png"))
    
    return try Layer(canvas.render())
}


private func makeCanvas(layer: Layer, canvas: CanvasKit.Canvas) throws {
    canvas.layers.remove(at: 0)
    
    let mask = try layer.select(by: .color(.black))
    let copy = try layer.copy(selection: mask)
    try copy.fill(color: .red, selection: copy.select())
    
    try copy.transform(.resize(to: .square(200)))
//    copy.origin = .zero
    
    
    let shadow = copy.copy()
    try shadow.fill(color: .black, selection: shadow.select())
    shadow.origin += CGPoint(x: 10, y: -10)
    
    canvas.add(layer: shadow)
    canvas.add(layer: copy)
}


let layer = try! makeSampleLayer()
let canvas = CanvasKit.Canvas(layer: layer)

try! makeCanvas(layer: layer, canvas: canvas)

try! FinderItem.downloadsDirectory.appending(path: "file.png").removeIfExists()
try! canvas.render().write(to: FinderItem.downloadsDirectory.appending(path: "file.png"))
