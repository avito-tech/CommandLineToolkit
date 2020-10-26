// swift-tools-version:5.2
import PackageDescription
let package = Package(
    name: "PackageGenerator",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "package-gen", targets: ["Bin"]),
    ],
    targets: [
        .target(
            name: "Bin",
            dependencies: ["PackageGenerator"]
        ),
        .target(
            name: "PackageGenerator",
            linkerSettings: [.unsafeFlags([])]
        ),
        .testTarget(
            name: "PackageGeneratorTests",
            dependencies: [
                "PackageGenerator",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
