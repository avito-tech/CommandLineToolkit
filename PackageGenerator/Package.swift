// swift-tools-version:5.9
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
        .executableTarget(
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
