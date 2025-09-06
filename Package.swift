// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CanvasKit",
    platforms: [.macOS(.v15), .iOS(.v18), .visionOS(.v2)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CanvasKit",
            targets: ["CanvasKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Vaida12345/MetalManager.git", from: "1.0.0"),
        .package(url: "https://github.com/Vaida12345/Optimization.git", from: "1.0.0"),
        .package(url: "https://github.com/Vaida12345/DetailedDescription.git", from: "2.0.0"),
        .package(url: "https://github.com/Vaida12345/FinderItem.git", from: "1.0.0"),
        .package(url: "https://github.com/Vaida12345/Matrix.git", from: "1.0.0"),
        .package(url: "https://github.com/Vaida12345/NativeImage.git", from: "1.0.0"),
        .package(url: "https://github.com/Vaida12345/ConcurrentStream.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CanvasKit",
            dependencies: ["MetalManager", "DetailedDescription", "Optimization", "FinderItem", "Matrix", "ConcurrentStream", "NativeImage"]
        ),
        .testTarget(
            name: "CanvasKitTests",
            dependencies: ["CanvasKit"]
        ),
        .executableTarget(name: "Client", dependencies: ["CanvasKit"])
    ]
)
