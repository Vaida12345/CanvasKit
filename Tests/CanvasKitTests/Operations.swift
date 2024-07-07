import Testing
import Foundation
@testable import CanvasKit
import Stratum

extension Tag {
    @Tag static let operations: Tag
}


@Suite("Operations", .tags(.operations))
struct Operations {
    
    let tempFolder: FinderItem
    
    
    func loadLayer(folder: String, name: String = "source.png") throws -> Layer {
        let source = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Operations/\(folder)/\(name)")
        assert(source.isReadable)
        
        let image = try source.load(.cgImage)
        return Layer(image, origin: .zero)
    }
    
    func writeAndCompare(layer: some LayerProtocol, folder: String, name: String = "result.png") throws {
        let result = tempFolder.appending(path: "\(UUID())_\(name)")
        try layer.render().write(to: result)
        try #require(result.contentsEqual(to: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Operations/\(folder)/\(name)"), "Check \"\(result.name)\" in the Temp folder.")
        try result.remove()
    }
    
    @Test func convolution() async throws {
        let folder = "convolution"
        let layer = try loadLayer(folder: folder)
        
        try layer.apply(
            .convolution(
                kernel: Matrix([
                    [1/273,  4/273,  7/273,  4/273,  1/273],
                    [4/273, 16/273, 26/273, 16/273,  4/273],
                    [7/273, 26/273, 41/273, 26/273,  7/273],
                    [4/273, 16/273, 26/273, 16/273,  4/273],
                    [1/273,  4/273,  7/273,  4/273,  1/273],
                ] as [[Float]])
            )
        )
        
        try writeAndCompare(layer: layer, folder: folder)
    }
    
    init() throws {
        self.tempFolder = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Temp/Operations")
        try tempFolder.makeDirectory()
    }
}
