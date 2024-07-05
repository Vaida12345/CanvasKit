import Testing
import Foundation
@testable import CanvasKit
import Stratum


@Suite("Operations")
struct TestOperations {
    
    @Test func delete() async throws {
        let source = FinderItem(at: "/Users/vaida/Downloads/box.png")
        assert(source.isReadable)
        
        let image = try source.load(.cgImage)
        let layer = Layer(image, origin: .zero)
        let mask = try layer.select(by: .color(.white, tolerance: 10))
        try print(mask.reverse().boundary)
        
        try layer.delete(selection: mask)
        try layer.render().write(to: FinderItem.desktopDirectory.appending(path: "result.png"))
    }
}
