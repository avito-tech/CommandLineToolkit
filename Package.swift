// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "AvitoSharedUtils",
    products: [
        .library(
            name: "Timer",
            targets: [
                "Timer"
            ]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            // MARK: Timer
            name: "Timer",
            dependencies: [
            ]
        ),
    ]
)
