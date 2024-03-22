import Foundation
import PackageGenerator
import XCTest

final class PackageJsonTests: XCTestCase {
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
                ],
                mirrorsFilePath: nil
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
                ],
                mirrorsFilePath: nil
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
    
    func test___mirrors_file_path___when_explicitly_set() throws {
        let jsonFile = PackageJsonFile(
            swiftToolsVersion: "",
            name: "",
            platforms: [],
            products: .explicit([]),
            dependencies: PackageDependencies(
                implicitSystemModules: [],
                external: [:],
                mirrorsFilePath: "/Users/test/my_project/my_mirrors.json"
            ),
            targets: .multiple([])
        )
        
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
             {
                "dependencies": {
                    "mirrorsFilePath": "/Users/test/my_project/my_mirrors.json",
                    "external": {},
                    "implicitSystemModules": []
                },
                "name": "",
                "platforms": [],
                "products": [],
                "swiftToolsVersion": "",
                "targets": [],
            }
            """
        )
    }
    
    func test___mirrors_file_path___when_not_explicitly_set() throws {
        let jsonFile = PackageJsonFile(
            swiftToolsVersion: "",
            name: "",
            platforms: [],
            products: .explicit([]),
            dependencies: PackageDependencies(
                implicitSystemModules: [],
                external: [:],
                mirrorsFilePath: nil
            ),
            targets: .multiple([])
        )
        
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
             {
                "dependencies": {
                    "external": {},
                    "implicitSystemModules": []
                },
                "name": "",
                "platforms": [],
                "products": [],
                "swiftToolsVersion": "",
                "targets": [],
            }
            """
        )
    }
}
