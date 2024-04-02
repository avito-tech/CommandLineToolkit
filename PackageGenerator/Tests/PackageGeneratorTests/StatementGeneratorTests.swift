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
                .package(url: "http://example.com/someexternalpackage", exact: "123"),
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
    
    func test___swift_settings() throws {
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
                                swiftSettings: SwiftSettings(values: [
                                    .define(name: "FOO"),
                                    .enableExperimentalFeature(name: "StrictConcurrency=complete"),
                                    .enableUpcomingFeature(name: "Hell"),
                                    .interoperabilityMode(mode: .CXX),
                                    .unsafeFlags(flags: ["Unsafe", "Flag"])
                                ])
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
                swiftSettings: [
                    .define("FOO"),
                    .enableExperimentalFeature("StrictConcurrency=complete"),
                    .enableUpcomingFeature("Hell"),
                    .interoperabilityMode(.CXX),
                    .unsafeFlags(["Unsafe", "Flag"]),
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
        
    func test___common_swift_settings() throws {
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
                                swiftSettings: SwiftSettings(values: [
                                    .define(name: "BAR")
                                ])
                            ),
                            conditionalCompilationTargetRequirement: nil
                        )
                    ),
                    commonSwiftSettings: SwiftSettings(values: [
                        .define(name: "FOO")
                    ])
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
                swiftSettings: [
                    .define("FOO"),
                    .define("BAR"),
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

    func test___external_dependencies_requirements() throws {
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
                        external: [
                            "A": ExternalPackageLocation.url(url: "http://g.com/foo", version: .exact("1.2.3"), importMappings: [:], targetNames: .generated),
                            "B": ExternalPackageLocation.url(url: "http://g.com/bar", version: .branch("master"), importMappings: [:], targetNames: .generated),
                            "C": ExternalPackageLocation.url(url: "http://g.com/baz", version: .revision("f123f"), importMappings: [:], targetNames: .generated),
                            "D": ExternalPackageLocation.url(url: "http://g.com/bra", version: .from("4.5.6"), importMappings: [:], targetNames: .generated)
                        ],
                        mirrorsFilePath: nil
                    ),
                    targets: PackageTargets.single(
                        PackageTarget(
                            name: "TargetA",
                            dependencies: [],
                            path: "Sources/TargetA",
                            isTest: false,
                            settings: TargetSpecificSettings(
                            ),
                            conditionalCompilationTargetRequirement: nil
                        )
                    ),
                    commonSwiftSettings: .empty
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
            ],
            products: [
            ],
            dependencies: [
                .package(url: "http://g.com/foo", exact: "1.2.3"),
                .package(url: "http://g.com/bar", branch: "master"),
                .package(url: "http://g.com/baz", revision: "f123f"),
                .package(url: "http://g.com/bra", from: "4.5.6"),
            ],
            targets: targets
        )

        """
        
        XCTAssertEqual(
            contents.first!.contents,
            expectedContents
        )
    }

    func test___ignore_common_swift_settings() throws {
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
                                swiftSettings: SwiftSettings(values: [
                                    .define(name: "BAR")
                                ]),
                                ignoreCommonSwiftSettings: true
                            ),
                            conditionalCompilationTargetRequirement: nil
                        )
                    ),
                    commonSwiftSettings: SwiftSettings(values: [
                        .define(name: "FOO")
                    ])
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
                swiftSettings: [
                    .define("BAR"),
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
