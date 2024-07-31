//
//  Utilities.swift
//  CanvasKit
//
//  Created by Vaida on 7/31/24.
//

import Testing
import CoreGraphics
import AppKit
import Stratum
import CanvasKit


func makeSampleCGImage() -> CGImage {
    let image = NSImage(systemSymbolName: "doc", accessibilityDescription: nil)!
    let sourceImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let context = CGContext(
        data: nil,
        width: sourceImage.width,
        height: sourceImage.height,
        bitsPerComponent: 8,
        bytesPerRow: 4 * sourceImage.width,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    context.draw(sourceImage, in: CGRect(origin: .zero, size: CGSize(width: sourceImage.width, height: sourceImage.height)))
    return context.makeImage()!
}

func assertCGImagesEqual(_ lhs: CGImage, _ rhs: CGImage) {
    let _lhs = lhs.dataProvider?.data as? Data
    let _rhs = rhs.dataProvider?.data as? Data
    
    #expect(_lhs == _rhs)
}


class TestingSuit {
    
    func tempFolder() throws -> FinderItem {
        let folder = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Temp/\(self.folder())")
        try folder.makeDirectory()
        return folder
    }
    
    func folder() -> String {
        fatalError()
    }
    
    
    func writeAndCompare(layer: some LayerProtocol, folder: String, name: String = "result.png") async throws {
        let result = try tempFolder().appending(path: folder + "/" + name)
        try result.generateDirectory()
        try await layer.render().write(to: result)
        try #require(result.contentsEqual(to: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/\(self.folder())/\(folder)/\(name)"), "Check \"\(folder + "/" + result.name)\" in the Temp folder.")
        try result.remove()
    }
}
