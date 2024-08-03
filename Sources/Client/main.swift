//
//  main.swift
//  
//
//  Created by Vaida on 7/10/24.
//

@preconcurrency
import Metal
import MetalManager
import CanvasKit
import Stratum

let context = try await MetalContext()

let red_layer = Layer(width: 100, height: 100, context: context)
try await red_layer.fill(.red)

let green_layer = Layer(width: 100, height: 100, context: context)
try await green_layer.fill(.green)

let canvas = Canvas(layers: [red_layer, green_layer])
let texture = try await canvas.makeTexture(width: 100, height: 100, context: context)

try await context.synchronize()

try texture.makeCGImage()!.write(to: FinderItem.downloadsDirectory.appending(path: "file.png"))
