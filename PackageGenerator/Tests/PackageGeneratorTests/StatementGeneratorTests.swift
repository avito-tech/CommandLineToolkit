@testable import PackageGenerator
import XCTest

// swiftlint:disable force_unwrapping
final class StatementGeneratorTests: XCTestCase {
    private lazy var statementGenerator = StatementGenerator()
    
    func test() throws {
        let contents = try statementGenerator.generatePackageSwiftCode(
            generatablePackage: GeneratablePackage(
                location: URL(fileURLWithPath: NSTemporaryDirectory()),
                packageJsonFile: PackageJsonFile(
                    swiftToolsVersion: "1.2",
                    name: "TestPackage",
                    platforms: [
                        PackagePlatform(name: "macOS", version: "10.15")
                    ],
                    products: PackageProducts.productForEachTarget,
                    dependencies: PackageDependencies(
                        implicitSystemModules: [],
                        external: [
                            "SomeExternalPackage": ExternalPackageLocation.url(
                                url: "http://example.com/someexternalpackage",
                                version: .exact("123"),
                                importMappings: [:],
                                targetNames: .targetNames(["SomeExternalModule"])
                            )
                        ],
                        mirrorsFilePath: nil
                    ),
                    targets: PackageTargets.single(
                        PackageTarget(
                            name: "TargetA",
                            dependencies: [],
                            path: "Sources/TargetA",
                            isTest: false,
                            settings: TargetSpecificSettings(linkerSettings: LinkerSettings(unsafeFlags: [])),
                            conditionalCompilationTargetRequirement: nil
                        )
                    )
                )
            )
        )
        
        let expectedContents = """
        // swift-tools-version:1.2
        import PackageDescription

        var targets = [Target]()
        // MARK: TargetA
        targets.append(
            .target(
                name: "TargetA",
                dependencies: [
                ],
                path: "Sources/TargetA"
            )
        )

        let package = Package(
            name: "TestPackage",
            platforms: [
                .macOS(.v10_15),
            ],
            products: [
                .library(name: "TargetA", targets: ["TargetA"]),
            ],
            dependencies: [
                .package(name: "SomeExternalPackage", url: "http://example.com/someexternalpackage", .exact("123")),
            ],
            targets: targets
        )

        """
        
        XCTAssertEqual(
            contents.first!.contents,
            expectedContents
        )
    }
    
    func test___multiple_targets() throws {
        let contents = try statementGenerator.generatePackageSwiftCode(
            generatablePackage: GeneratablePackage(
                location: URL(fileURLWithPath: NSTemporaryDirectory()),
                packageJsonFile: PackageJsonFile(
                    swiftToolsVersion: "1.2",
                    name: "TestPackage",
                    platforms: [],
                    products: PackageProducts.explicit([]),
                    dependencies: PackageDependencies(
                        implicitSystemModules: [],
                        external: [:],
                        mirrorsFilePath: nil
                    ),
                    targets: .multiple(
                        [
                            PackageTargets.single(
                                PackageTarget(
                                    name: "TargetA",
                                    dependencies: [],
                                    path: "Sources/TargetA",
                                    isTest: false,
                                    settings: TargetSpecificSettings(
                                        linkerSettings: LinkerSettings(
                                            unsafeFlags: []
                                        )
                                    ),
                                    conditionalCompilationTargetRequirement: nil
                                )
                            ),
                            PackageTargets.single(
                                PackageTarget(
                                    name: "TargetB",
                                    dependencies: [],
                                    path: "Sources/TargetB",
                                    isTest: false,
                                    settings: TargetSpecificSettings(
                                        linkerSettings: LinkerSettings(
                                            unsafeFlags: []
                                        )
                                    ),
                                    conditionalCompilationTargetRequirement: nil
                                )
                            )
                        ]
                    )
                )
            )
        )
        
        let expectedContents = """
        // swift-tools-version:1.2
        import PackageDescription

        var targets = [Target]()
        // MARK: TargetA
        targets.append(
            .target(
                name: "TargetA",
                dependencies: [
                ],
                path: "Sources/TargetA"
            )
        )
        // MARK: TargetB
        targets.append(
            .target(
                name: "TargetB",
                dependencies: [
                ],
                path: "Sources/TargetB"
            )
        )

        let package = Package(
            name: "TestPackage",
            platforms: [
            ],
            products: [
            ],
            dependencies: [
            ],
            targets: targets
        )

        """
        
        XCTAssertEqual(
            contents.first!.contents,
            expectedContents
        )
    }
    
    func test___linker_settings() throws {
        let contents = try statementGenerator.generatePackageSwiftCode(
            generatablePackage: GeneratablePackage(
                location: URL(fileURLWithPath: NSTemporaryDirectory()),
                packageJsonFile: PackageJsonFile(
                    swiftToolsVersion: "1.2",
                    name: "TestPackage",
                    platforms: [],
                    products: PackageProducts.explicit([]),
                    dependencies: PackageDependencies(
                        implicitSystemModules: [],
                        external: [:],
                        mirrorsFilePath: nil
                    ),
                    targets: PackageTargets.single(
                        PackageTarget(
                            name: "TargetA",
                            dependencies: [],
                            path: "Sources/TargetA",
                            isTest: false,
                            settings: TargetSpecificSettings(
                                linkerSettings: LinkerSettings(
                                    unsafeFlags: ["some", "flags"]
                                )
                            ),
                            conditionalCompilationTargetRequirement: nil
                        )
                    )
                )
            )
        )
        
        let expectedContents = """
        // swift-tools-version:1.2
        import PackageDescription

        var targets = [Target]()
        // MARK: TargetA
        targets.append(
            .target(
                name: "TargetA",
                dependencies: [
                ],
                path: "Sources/TargetA",
                linkerSettings: [
                    .unsafeFlags(["some", "flags"]),
                ]
            )
        )

        let package = Package(
            name: "TestPackage",
            platforms: [
            ],
            products: [
            ],
            dependencies: [
            ],
            targets: targets
        )

        """
        
        XCTAssertEqual(
            contents.first!.contents,
            expectedContents
        )
    }
    
    func test___os_requirements_for_targets() throws {
        let contents = try statementGenerator.generatePackageSwiftCode(
            generatablePackage: GeneratablePackage(
                location: URL(fileURLWithPath: NSTemporaryDirectory()),
                packageJsonFile: PackageJsonFile(
                    swiftToolsVersion: "1.2",
                    name: "TestPackage",
                    platforms: [],
                    products: PackageProducts.explicit([]),
                    dependencies: PackageDependencies(
                        implicitSystemModules: [],
                        external: [:],
                        mirrorsFilePath: nil
                    ),
                    targets: PackageTargets.single(
                        PackageTarget(
                            name: "TargetA",
                            dependencies: [],
                            path: "Sources/TargetA",
                            isTest: false,
                            settings: TargetSpecificSettings(
                                linkerSettings: LinkerSettings(
                                    unsafeFlags: ["some", "flags"]
                                )
                            ),
                            conditionalCompilationTargetRequirement: .os(.Linux)
                        )
                    )
                )
            )
        )
        
        let expectedContents = """
        // swift-tools-version:1.2
        import PackageDescription

        var targets = [Target]()
        #if os(Linux)
        // MARK: TargetA
        targets.append(
            .target(
                name: "TargetA",
                dependencies: [
                ],
                path: "Sources/TargetA",
                linkerSettings: [
                    .unsafeFlags(["some", "flags"]),
                ]
            )
        )
        #endif

        let package = Package(
            name: "TestPackage",
            platforms: [
            ],
            products: [
            ],
            dependencies: [
            ],
            targets: targets
        )

        """
        
        XCTAssertEqual(
            contents.first!.contents,
            expectedContents
        )
    }
    
    func test___exclude_settings() throws {
        let contents = try statementGenerator.generatePackageSwiftCode(
            generatablePackage: GeneratablePackage(
                location: URL(fileURLWithPath: NSTemporaryDirectory()),
                packageJsonFile: PackageJsonFile(
                    swiftToolsVersion: "1.2",
                    name: "TestPackage",
                    platforms: [],
                    products: PackageProducts.explicit([]),
                    dependencies: PackageDependencies(
                        implicitSystemModules: [],
                        external: [:],
                        mirrorsFilePath: nil
                    ),
                    targets: PackageTargets.single(
                        PackageTarget(
                            name: "TargetA",
                            dependencies: [],
                            path: "Sources/TargetA",
                            isTest: false,
                            settings: TargetSpecificSettings(
                                linkerSettings: LinkerSettings(
                                    unsafeFlags: ["some", "flags"]
                                ),
                                excludePaths: .multiple(["README.md", "target.json"])
                            ),
                            conditionalCompilationTargetRequirement: nil
                        )
                    )
                )
            )
        )
        
        let expectedContents = """
        // swift-tools-version:1.2
        import PackageDescription

        var targets = [Target]()
        // MARK: TargetA
        targets.append(
            .target(
                name: "TargetA",
                dependencies: [
                ],
                path: "Sources/TargetA",
                exclude: [
                    "README.md",
                    "target.json",
                ],
                linkerSettings: [
                    .unsafeFlags(["some", "flags"]),
                ]
            )
        )

        let package = Package(
            name: "TestPackage",
            platforms: [
            ],
            products: [
            ],
            dependencies: [
            ],
            targets: targets
        )

        """
        
        XCTAssertEqual(
            contents.first!.contents,
            expectedContents
        )
    }
}
