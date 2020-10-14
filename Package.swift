// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "CommandLineToolkit",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "CommandLineToolkit",
            targets: [
                "Types",
            ]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            // MARK: Types
            name: "Types",
            dependencies: [
            ],
            path: "Sources/Types"
        ),
        .testTarget(
            // MARK: TypesTests
            name: "TypesTests",
            dependencies: [
                "Types",
            ],
            path: "Tests/TypesTests"
        ),
    ]
)
