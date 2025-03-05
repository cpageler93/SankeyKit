// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SankeyKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
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
