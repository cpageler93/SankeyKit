// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SankeyKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SankeyKit",
            targets: ["SankeyKit"]
        )
    ],
    targets: [
        .target(
            name: "SankeyKit"
        ),
        .testTarget(
            name: "SankeyKitTests",
            dependencies: ["SankeyKit"]
        )
    ]
)
