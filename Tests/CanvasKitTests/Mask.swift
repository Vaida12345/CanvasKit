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


extension Tag {
    @Tag static var mask: Tag
}


@Suite(.tags(.mask))
struct MaskSuit {
    
    let tempFolder: FinderItem
    
    @Test func mask_init_fill() async throws {
        try await writeAndCompare(
            layer: Mask(repeating: 0, width: 100, height: 100, context: MetalContext()),
            folder: "mask_init_fill",
            name: "mask_fill_zero.png"
        )
        
        try await writeAndCompare(
            layer: Mask(repeating: 255, width: 100, height: 100, context: MetalContext()),
            folder: "mask_init_fill",
            name: "mask_fill_full.png"
        )
        
        try await writeAndCompare(
            layer: Mask(repeating: 100, width: 100, height: 100, context: MetalContext()),
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
    
    func writeAndCompare(layer: some LayerProtocol, folder: String, name: String = "result.png") async throws {
        let result = tempFolder.appending(path: folder + "/" + name)
        try result.generateDirectory()
        try await layer.render().write(to: result)
        try #require(result.contentsEqual(to: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Mask/\(folder)/\(name)"), "Check \"\(folder + "/" + result.name)\" in the Temp folder.")
        try result.remove()
    }
    
    init() throws {
        self.tempFolder = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Temp/Mask")
        try tempFolder.makeDirectory()
    }
}

