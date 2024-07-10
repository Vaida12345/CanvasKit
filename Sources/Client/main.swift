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
    let layer = try Layer(fill: .clear, width: 256, height: 256)
    
    try layer.fill(color: .black, selection: Mask(width: 256, height: 256, selecting: CGRect(x: 32, y: 32, width: 256 - 32 * 2, height: 256 - 32 * 2)))
    try layer.delete(selection: Mask(width: 256, height: 256, selecting: CGRect(x: 64, y: 64, width: 256 - 64 * 2, height: 256 - 64 * 2)))
    
    return layer
}

let layer = try! makeSampleLayer()
try layer.transform(.resize(to: .square(200)))

try layer.render().write(to: FinderItem.downloadsDirectory.appending(path: "file.png"))

//try lanczosResample(inputImage: layer.render(), outputSize: .square(200))!.write(to: FinderItem.downloadsDirectory.appending(path: "file.png"))
