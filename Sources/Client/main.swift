//
//  main.swift
//  
//
//  Created by Vaida on 7/10/24.
//

import Stratum
@testable
import CanvasKit
import AppKit

let destination = FinderItem.downloadsDirectory.appending(path: "Tests")
try destination.removeIfExists()
try destination.makeDirectory()

let focusRect = CGRect(x: 333, y: 376, width: 359, height: 359)

for i in 0..<10 {
    let canvas = Canvas(width: 1024, height: 1024)
    
    let configuration = NSImage.SymbolConfiguration(pointSize: 359, weight: .regular, scale: .large)
    let image = NSImage(systemSymbolName: "shippingbox", accessibilityDescription: nil)!.withSymbolConfiguration(configuration)!.cgImage!
    
    let focusLayer = Layer(image)
    try focusLayer.crop(to: focusLayer.select().boundary)
    try focusLayer.transform(.aspectRatio(.fit, in: focusRect))
    let focusSelection = try focusLayer.select()
    try focusLayer.fill(color: .init(red: 94, green: 168, blue: 224), selection: focusSelection)
    canvas.add(layer: focusLayer)
    
    let shadow = try Layer(fill: .init(red: 255, green: 255, blue: 255, alpha: 43), frame: focusLayer.frame)
    try shadow.fill(red: nil, green: nil, blue: nil, alpha: 0, selection: focusSelection.invert())
    let rect = CGRect(center: shadow.size.center, size: CGSize(width: 400, height: 400))
    try shadow.expand(to: rect)
    
    try shadow.apply(.convolution(kernel: Matrix<Float>.gaussianBlurKernel(size: 7, distribution: 5), layers: .alpha))
    try shadow.fill(red: nil, green: nil, blue: nil, alpha: 0, selection: focusSelection.expanding(to: CGRect(center: focusSelection.size.center, size: CGSize(width: 400, height: 400))))
    shadow.origin += CGPoint(x: 0, y: 3)
    canvas.add(layer: shadow)
    
    let innerShadow = try Layer(fill: .init(red: 0, green: 0, blue: 0, alpha: 25), frame: focusLayer.frame)
    try innerShadow.fill(red: nil, green: nil, blue: nil, alpha: 0, selection: focusSelection)
    try innerShadow.expand(to: CGRect(center: focusRect.center, size: CGSize(width: 400, height: 400)))
    try innerShadow.apply(.convolution(kernel: Matrix<Float>.gaussianBlurKernel(size: 7, distribution: 5), layers: .alpha))
    canvas.add(layer: innerShadow)
    
    try canvas.render().write(to: destination.appending(path: "blend \(i).heic"))
}
