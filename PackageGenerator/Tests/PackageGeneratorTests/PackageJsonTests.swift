import Foundation
import PackageGenerator
import XCTest

final class PackageJsonTests: XCTestCase {
    lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        return encoder
    }()
    lazy var jsonDecoder = JSONDecoder()
    
    func test___basic() throws {
        let jsonFile = PackageJsonFile(
            swiftToolsVersion: "swift-version",
            name: "package name",
            platforms: [],
            products: .explicit([]),
            dependencies: PackageDependencies(
                implicitSystemModules: ["Foundation"],
                external: [
                    "ExternalPackageName": .url(
                        url: "http://github.com/whatever/ExternalPackageName",
                        version: .from("12.34"),
                        importMappings: [:],
                        targetNames: .targetNames(["ExternalPackageName"])
                    ),
                ]
            ),
            targets: .discoverAutomatically
        )
        
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
             {
                "dependencies": {
                    "external": {
                        "ExternalPackageName": {
                            "importMappings": {
            
                            },
                            "targetNames": [
                                "ExternalPackageName"
                            ],
                            "url": "http://github.com/whatever/ExternalPackageName",
                            "version": {
                                "from": "12.34"
                            }
                        }
                    },
                    "implicitSystemModules": [
                        "Foundation"
                    ]
                },
                "name": "package name",
                "platforms": [

                ],
                "products": [

                ],
                "swiftToolsVersion": "swift-version",
                "targets": "discoverAutomatically"
            }
            """
        )
    }
    
    func test___conditional_os_requirement() throws {
        let jsonFile = PackageJsonFile(
            swiftToolsVersion: "swift-version",
            name: "package name",
            platforms: [],
            products: .explicit([]),
            dependencies: PackageDependencies(
                implicitSystemModules: ["Foundation"],
                external: [
                    "ExternalPackageName": .url(
                        url: "http://github.com/whatever/ExternalPackageName",
                        version: .from("12.34"),
                        importMappings: [:],
                        targetNames: .targetNames(["ExternalPackageName"])
                    ),
                ]
            ),
            targets: .single(
                PackageTarget(
                    name: "targetForLinuxOnly",
                    dependencies: [],
                    path: "path",
                    isTest: false,
                    settings: TargetSpecificSettings(linkerSettings: LinkerSettings(unsafeFlags: [])),
                    conditionalCompilationTargetRequirement: .os(.Linux)
                )
            )
        )
        
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
            {
                "dependencies": {
                    "external": {
                        "ExternalPackageName": {
                            "importMappings": {

                            },
                            "targetNames": [
                                "ExternalPackageName"
                            ],
                            "url": "http://github.com/whatever/ExternalPackageName",
                            "version": {
                                "from": "12.34"
                            }
                        }
                    },
                    "implicitSystemModules": [
                        "Foundation"
                    ]
                },
                "name": "package name",
                "platforms": [

                ],
                "products": [

                ],
                "swiftToolsVersion": "swift-version",
                "targets": {
                    "name": "targetForLinuxOnly",
                    "dependencies": [],
                    "path": "path",
                    "isTest": false,
                    "settings": {
                        "linkerSettings": {
                            "unsafeFlags": [

                            ]
                        }
                    },
                    "conditionalCompilationTargetRequirement": {
                        "os": "Linux"
                    }
                }
            }
            """
        )
    }
    
    private func assert(
        jsonFile: PackageJsonFile,
        equalsJsonRepresentation: String
    ) throws {
        let parsedFile = try jsonDecoder.decodeExplaining(
            PackageJsonFile.self,
            from: Data(equalsJsonRepresentation.utf8)
        )
        
        if jsonFile != parsedFile {
            print("Expected JSON representation:")
            print(try jsonEncoder.encode(jsonFile))
            XCTFail("Result mismatch, see logs")
        }
    }
}