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
    
    func test___pathString___provides_path___for_empty_components() {
        XCTAssertEqual(
            RelativePath(components: [String]()).pathString,
            "./"
        )
    }
    
    func test___removingLastComponent___removes_component___if_path_is_not_empty() {
        let path = RelativePath(components: ["two"])
        XCTAssertEqual(
            path.removingLastComponent.pathString,
            "./"
        )
    }
    
    func test___removingLastComponent___returns_same_path___if_path_is_empty() {
        let path = RelativePath(components: [String]())
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
