import Testing
import Foundation
@testable import CanvasKit
import Stratum

extension Tag {
    @Tag static let select: Tag
}


@Suite("Operations", .tags(.select))
struct SelectOperations {
    
    let tempFolder: FinderItem
    
    
    func loadLayer(folder: String, name: String = "source.png") throws -> Layer {
        let source = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/TestOperations/select/\(folder)/\(name)")
        assert(source.isReadable)
        
        let image = try source.load(.cgImage)
        return Layer(image, origin: .zero)
    }
    
    func writeAndCompare(layer: Layer, folder: String, name: String = "result.png") throws {
        let result = tempFolder.appending(path: "\(UUID())_\(name)")
        try layer.render().write(to: result)
        try #require(result.contentsEqual(to: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/TestOperations/select/\(folder)/\(name)"), "Check \"\(result.name)\" in the Temp folder.")
    }
    
    @Test func selectByColor() async throws {
        let folder = "selectByColor"
        let layer = try loadLayer(folder: folder)
        
        let mask = try layer.select(by: .color(.white, tolerance: 10))
        try layer.delete(selection: mask)
        
        try writeAndCompare(layer: layer, folder: folder)
    }
    
    @Test func selectByVisible() async throws {
        let folder = "selectByVisible"
        let layer = try loadLayer(folder: folder, name: "source.heic")

        let mask = try layer.select(by: .visible())
        try layer.fill(color: .white, selection: mask.inverse())
        
        try writeAndCompare(layer: layer, folder: folder, name: "result.heic")
    }
    
    @Test func selectByColorPoint() async throws {
        let folder = "selectByColor"
        let layer = try loadLayer(folder: folder)
        
        let mask = try layer.select(by: .color(at: CGPoint(x: 128, y: 128)))
        try layer.delete(selection: mask)
        
        try writeAndCompare(layer: layer, folder: folder, name: "point_result.png")
    }
    
    @Test func maskBoundary() async throws {
        let layer = try loadLayer(folder: "selectByColor")
        
        let mask = try layer.select(by: .color(.white, tolerance: 10))
        try layer.crop(to: mask.inverse().boundary)
        
        try writeAndCompare(layer: layer, folder: "maskBoundary")
    }
    
    init() throws {
        self.tempFolder = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Temp")
        try tempFolder.removeIfExists()
        try tempFolder.makeDirectory()
    }
}
