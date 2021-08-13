import Foundation
import PathLib
import TestHelpers
import XCTest

// swiftlint:disable multiple_closures_with_trailing_closure

class RelativePathTests: XCTestCase {
    func test() {
        let path = RelativePath(components: ["one", "two"])
        XCTAssertEqual(path.pathString, "one/two")
    }
    
    func test___empty_components() {
        XCTAssertEqual(
            RelativePath(components: []).pathString,
            "./"
        )
    }
    
    func test___removing_last_path_component() {
        let path = RelativePath(components: ["two"])
        XCTAssertEqual(
            path.removingLastComponent.pathString,
            "./"
        )
    }
    
    func test___removing_last_path_component_from_componentless_path() {
        let path = RelativePath(components: [])
        XCTAssertEqual(
            path.removingLastComponent.pathString,
            "./"
        )
    }
    
    func test___appending() {
        let path = RelativePath("some/path")
        XCTAssertEqual(path.appending("another", "subpath").pathString, "some/path/another/subpath")
    }
    
    func test___validating() {
        assertThrows {
            try RelativePath.validating(string: "/not/relative/path")
        }
        
        assert {
            try RelativePath.validating(string: "some/path")
        } equals: {
            RelativePath("some/path")
        }
    }
}
