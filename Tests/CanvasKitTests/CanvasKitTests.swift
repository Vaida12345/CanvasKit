import Testing
import Foundation
@testable import CanvasKit
import Stratum


@Suite("Operations")
struct TestOperations {
    
    let tempFolder: FinderItem
    
    @Test func selectByColor() async throws {
        let source = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/TestOperations/selectByColor/box.png")
        assert(source.isReadable)
        
        let image = try source.load(.cgImage)
        let layer = Layer(image, origin: .zero)
        let mask = try layer.select(by: .color(.white, tolerance: 10))
        
        let maskResult = tempFolder.appending(path: "\(UUID())_mask.png")
        try mask.render().write(to: maskResult)
        
        try layer.delete(selection: mask)
        let result = tempFolder.appending(path: "\(UUID()).png")
        try layer.render().write(to: result)
        try #require(result.contentsEqual(to: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/TestOperations/selectByColor/result.png"), "Check \"\(result.name)\" in the Temp folder.")
    }
    
    @Test func selectByColorPoint() async throws {
        let source = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/TestOperations/selectByColor/box.png")
        assert(source.isReadable)
        
        let image = try source.load(.cgImage)
        let layer = Layer(image, origin: .zero)
        let mask = try layer.select(by: .color(at: CGPoint(x: 128, y: 128)))
        
        let maskResult = tempFolder.appending(path: "mask_\(UUID()).png")
        try mask.render().write(to: maskResult)
        
        try layer.delete(selection: mask)
        let result = tempFolder.appending(path: "\(UUID()).png")
        try layer.render().write(to: result)
        try #require(result.contentsEqual(to: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/TestOperations/selectByColor/point_result.png"), "Check \"\(result.name)\" in the Temp folder.")
    }
    
    @Test func maskBoundary() async throws {
        let source = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/TestOperations/selectByColor/box.png")
        assert(source.isReadable)
        
        let image = try source.load(.cgImage)
        let layer = Layer(image, origin: .zero)
        let mask = try layer.select(by: .color(.white, tolerance: 10))
        
        try layer.crop(to: mask.reverse().boundary)
        let result = tempFolder.appending(path: "\(UUID()).png")
        try layer.render().write(to: result)
        try #require(result.contentsEqual(to: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/TestOperations/maskBoundary/result.png"), "Check \"\(result.name)\" in the Temp folder.")
    }
    
    init() throws {
        self.tempFolder = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/CanvasKit/Tests/CanvasKitTests/Resources/Temp")
        try tempFolder.removeIfExists()
        try tempFolder.makeDirectory()
    }
}
