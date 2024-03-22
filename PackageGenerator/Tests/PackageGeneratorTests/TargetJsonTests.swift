import Foundation
import XCTest
@testable import PackageGenerator

final class TargetJsonTests: XCTestCase {
    func test___empty() throws {
        let jsonFile = TargetSpecificSettings(linkerSettings: .init(unsafeFlags: []))
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
            {
            }
            """
            )
    }
    
    func test__linker_unsafe_flags() throws {
        let jsonFile = TargetSpecificSettings(
            linkerSettings: .init(unsafeFlags: ["-Xlinker", "-framework", "-Xlinker", "PackageKit"]),
            excludePaths: .single("target.json")
        )
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
            {
              "linkerSettings" : {
                "unsafeFlags" : [
                  "-Xlinker",
                  "-framework",
                  "-Xlinker",
                  "PackageKit"
                ]
              }
            }
            """
        )
    }
    
    func test___exclude_single_path() throws {
        let jsonFile = TargetSpecificSettings(
            linkerSettings: .init(unsafeFlags: []),
            excludePaths: .multiple(["Readme.md", "target.json"])
        )
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
            {
              "exclude" : "Readme.md"
            }
            """
        )
    }
    
    func test___exclude_multiple_path() throws {
        let jsonFile = TargetSpecificSettings(
            linkerSettings: .init(unsafeFlags: []),
            excludePaths: .multiple(["Readme.md", "Test.swift", "target.json"])
        )
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
            {
              "exclude" : [
                "Readme.md",
                "Test.swift"
                ]
            }
            """
        )
    }
    
    func test__swift_setting() throws {
        let settings: [SwiftSetting] = [
            .define(name: "ABCD"),
            .enableExperimentalFeature(name: "StrictConcurrency=complete"),
            .enableUpcomingFeature(name: "Upcoming"),
            .interoperabilityMode(mode: .C),
            .unsafeFlags(flags: ["First", "Second"])
        ]
        let jsonFile = TargetSpecificSettings(
            excludePaths: .single("target.json"),
            swiftSettings: SwiftSettings(values: settings)
        )
        
        try assert(
            jsonFile: jsonFile,
            equalsJsonRepresentation: """
                {
                  "swiftSettings" : [
                    {
                      "define" : {
                        "name" : "ABCD"
                      }
                    },
                    {
                      "enableExperimentalFeature" : {
                        "name" : "StrictConcurrency=complete"
                      }
                    },
                    {
                      "enableUpcomingFeature" : {
                        "name" : "Upcoming"
                      }
                    },
                    {
                      "interoperabilityMode" : {
                        "mode" : "C"
                      }
                    },
                    {
                      "unsafeFlags" : {
                        "flags" : [
                          "First",
                          "Second"
                        ]
                      }
                    }
                  ]
                }
            """
        )
    }
}
