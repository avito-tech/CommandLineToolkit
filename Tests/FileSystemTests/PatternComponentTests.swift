import FileSystem
import Foundation
import PathLib
import TestHelpers
import XCTest

// swiftlint:disable multiple_closures_with_trailing_closure
final class GlobPatternTests: XCTestCase {
    func test___any_file_anywhere() {
        assert {
            GlobPattern
                .rootingAt(.root)
                .concat("**/*")
                .value
        } equals: {
            "/**/*"
        }
    }
    
    func test___some_images() {
        assert {
            GlobPattern
                .rootingAt(AbsolutePath(components: ["Users", "username", "Pictures"]))
                .concat("/*.{jpg,png,tiff}")
                .value
        } equals: {
            "/Users/username/Pictures/*.{jpg,png,tiff}"
        }
    }
    
    func test___decoding() {
        assert {
            try JSONDecoder().decode(GlobPattern.self, from: Data("\"/path/to/**\"".utf8))
        } equals: {
            GlobPattern.rootingAt("/path/to").concat("/**")
        }
    }
    
    func test___decode_fails___when_glob_is_not_absolute() {
        assertThrows {
            try JSONDecoder().decode(GlobPattern.self, from: Data("\"some/path/**\"".utf8))
        }
        
        assertThrows {
            try JSONDecoder().decode(GlobPattern.self, from: Data("\"~/path/**\"".utf8))
        }
    }
}
