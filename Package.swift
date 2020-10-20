// swift-tools-version:5.2
import PackageDescription
let package = Package(
    name: "CommandLineToolkit",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "DateProvider", targets: ["DateProvider"]),
        .library(name: "DateProviderTestHelpers", targets: ["DateProviderTestHelpers"]),
        .library(name: "FileSystem", targets: ["FileSystem"]),
        .library(name: "FileSystemTestHelpers", targets: ["FileSystemTestHelpers"]),
        .library(name: "FileSystemTests", targets: ["FileSystemTests"]),
        .library(name: "PathLib", targets: ["PathLib"]),
        .library(name: "PathLibTests", targets: ["PathLibTests"]),
        .library(name: "PlistLib", targets: ["PlistLib"]),
        .library(name: "PlistLibTests", targets: ["PlistLibTests"]),
        .library(name: "TemporaryStuffTests", targets: ["TemporaryStuffTests"]),
        .library(name: "TestHelpers", targets: ["TestHelpers"]),
        .library(name: "Tmp", targets: ["Tmp"]),
        .library(name: "TmpTestHelpers", targets: ["TmpTestHelpers"]),
        .library(name: "Types", targets: ["Types"]),
        .library(name: "TypesTests", targets: ["TypesTests"]),
        .library(name: "XcodeLocator", targets: ["XcodeLocator"]),
        .library(name: "XcodeLocatorModels", targets: ["XcodeLocatorModels"]),
        .library(name: "XcodeLocatorTests", targets: ["XcodeLocatorTests"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DateProvider",
            dependencies: [
            ],
            path: "Sources/DateProvider"
        ),
        .target(
            name: "DateProviderTestHelpers",
            dependencies: [
                "DateProvider",
            ],
            path: "Tests/DateProviderTestHelpers"
        ),
        .target(
            name: "FileSystem",
            dependencies: [
                "PathLib",
            ],
            path: "Sources/FileSystem"
        ),
        .target(
            name: "FileSystemTestHelpers",
            dependencies: [
                "FileSystem",
                "PathLib",
            ],
            path: "Tests/FileSystemTestHelpers"
        ),
        .testTarget(
            name: "FileSystemTests",
            dependencies: [
                "DateProvider",
                "FileSystem",
                "PathLib",
                "TestHelpers",
                "Tmp",
                "TmpTestHelpers",
            ],
            path: "Tests/FileSystemTests"
        ),
        .target(
            name: "PathLib",
            dependencies: [
            ],
            path: "Sources/PathLib"
        ),
        .testTarget(
            name: "PathLibTests",
            dependencies: [
                "PathLib",
            ],
            path: "Tests/PathLibTests"
        ),
        .target(
            name: "PlistLib",
            dependencies: [
            ],
            path: "Sources/PlistLib"
        ),
        .testTarget(
            name: "PlistLibTests",
            dependencies: [
                "PlistLib",
                "TestHelpers",
            ],
            path: "Tests/PlistLibTests"
        ),
        .testTarget(
            name: "TemporaryStuffTests",
            dependencies: [
                "PathLib",
                "TestHelpers",
                "Tmp",
            ],
            path: "Tests/TemporaryStuffTests"
        ),
        .target(
            name: "TestHelpers",
            dependencies: [
            ],
            path: "Tests/TestHelpers"
        ),
        .target(
            name: "Tmp",
            dependencies: [
                "PathLib",
            ],
            path: "Sources/Tmp"
        ),
        .target(
            name: "TmpTestHelpers",
            dependencies: [
                "TestHelpers",
                "Tmp",
            ],
            path: "Tests/TmpTestHelpers"
        ),
        .target(
            name: "Types",
            dependencies: [
            ],
            path: "Sources/Types"
        ),
        .testTarget(
            name: "TypesTests",
            dependencies: [
                "Types",
            ],
            path: "Tests/TypesTests"
        ),
        .target(
            name: "XcodeLocator",
            dependencies: [
                "FileSystem",
                "PathLib",
                "PlistLib",
                "XcodeLocatorModels",
            ],
            path: "Sources/XcodeLocator"
        ),
        .target(
            name: "XcodeLocatorModels",
            dependencies: [
                "PathLib",
            ],
            path: "Sources/XcodeLocatorModels"
        ),
        .testTarget(
            name: "XcodeLocatorTests",
            dependencies: [
                "FileSystem",
                "FileSystemTestHelpers",
                "PlistLib",
                "TestHelpers",
                "TmpTestHelpers",
                "XcodeLocator",
                "XcodeLocatorModels",
            ],
            path: "Tests/XcodeLocatorTests"
        ),
    ]
)
