import Testing
import Foundation
@testable import CanvasKit
import Stratum

extension Tag {
    @Tag static let foundation: Tag
}


@Suite("Operations", .tags(.foundation))
struct CanvasFoundationTests {
    
    let tempFolder: FinderItem
    
    
    func loadLayer(folder: String, name: String = "source.png") throws -> Layer {
        let source = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Foundation/layers/\(folder)/\(name)")
        assert(source.isReadable)
        
        let image = try source.load(.cgImage)
        return Layer(image, origin: .zero)
    }
    
    func writeAndCompare(layer: some LayerProtocol, folder: String, name: String = "result.png") throws {
        let result = tempFolder.appending(path: "\(UUID())_\(name)")
        try layer.render().write(to: result)
        try #require(result.contentsEqual(to: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Foundation/layers/\(folder)/\(name)"), "Check \"\(result.name)\" in the Temp folder.")
    }
    
    @Test func layersMix() async throws {
        let folder = "layersMix"
        let layer = try loadLayer(folder: folder, name: "source.heic")
        
        let canvas = Canvas(layer: layer)
        try canvas.layers.insert(Layer(fill: .white, width: layer.width, height: layer.height, origin: .zero), at: 0)
        
        try writeAndCompare(layer: canvas, folder: folder, name: "result.heic")
    }
    
    @Test func layersMix2() async throws {
        let folder = "layersMix2"
        let layer = try Layer(fill: .white, width: 50, height: 100)
        
        let canvas = Canvas(width: 200, height: 200)
        try canvas.add(layer: Layer(fill: .init(red: 255, green: 0, blue: 0), width: 100, height: 100), transformations: .aspectRatio(.fit, in: CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 100, height: 100))))
        try canvas.add(layer: layer, transformations: .aspectRatio(.fit, in: CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 100, height: 100))))
        
        try writeAndCompare(layer: canvas, folder: folder, name: "result.heic")
    }
    
    init() throws {
        self.tempFolder = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Temp/CanvasFoundationTests")
        try tempFolder.removeIfExists()
        try tempFolder.makeDirectory()
    }
}
