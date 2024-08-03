// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CanvasKit",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CanvasKit",
            targets: ["CanvasKit"]),
    ],
    dependencies: [
        .package(name: "MetalManager",
                 path: "~/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/MetalManager"),
        .package(name: "Stratum",
                 path: "~/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/Stratum")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CanvasKit",
            dependencies: ["MetalManager", "Stratum"]
        ),
        .testTarget(
            name: "CanvasKitTests",
            dependencies: ["CanvasKit", "Stratum"]
        ),
        .executableTarget(name: "Client", dependencies: ["CanvasKit", "Stratum"])
    ]
)
