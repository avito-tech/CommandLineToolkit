import Foundation
import PathLib
import TestHelpers
import XCTest

// swiftlint:disable multiple_closures_with_trailing_closure

class AbsolutePathTests: XCTestCase {
    
    func test___create_from_components___file_path() {
        let path = AbsolutePath(components: ["one", "two", "file"])
        XCTAssertEqual(
            path.pathString,
            "/one/two/file"
        )
    }
    
    func test___removing_last_component() {
        let path = AbsolutePath(components: ["one", "two", "file"])
        XCTAssertEqual(
            path.removingLastComponent.pathString,
            "/one/two"
        )
    }
    
    func test___last_component() {
        let path = AbsolutePath(components: ["one", "two", "file"])
        XCTAssertEqual(
            path.lastComponent,
            "file"
        )
    }
    
    func test___last_component___when_absolute_path_is_root() {
        XCTAssertEqual(
            AbsolutePath.root.lastComponent,
            "/"
        )
    }
    
    func test___removing_last_path_component_from_componentless_path() {
        let path = AbsolutePath(components: [String]())
        XCTAssertEqual(
            path.removingLastComponent.pathString,
            "/"
        )
    }
    
    func test___relative_path_computation() {
        let anchor = AbsolutePath("/one/two")
        let path = AbsolutePath("/one/two/three/four")

        XCTAssertEqual(
            path.relativePath(anchorPath: anchor),
            RelativePath("three/four")
        )
    }
    
    func test___relative_path_computation_reversed() {
        let path = AbsolutePath("/one/two")
        let anchor = AbsolutePath("/one/two/three/four")
        
        XCTAssertEqual(
            path.relativePath(anchorPath: anchor),
            RelativePath("../..")
        )
    }
    
    func test___is_subpath() {
        XCTAssertTrue(
            AbsolutePath("/path/to/something").isSubpathOf(anchorPath: AbsolutePath("/path/to/"))
        )
        XCTAssertFalse(
            AbsolutePath("/path/to/something").isSubpathOf(anchorPath: AbsolutePath("/path/to/something"))
        )
        XCTAssertFalse(
            AbsolutePath("/path/of/something").isSubpathOf(anchorPath: AbsolutePath("/path/to/"))
        )
    }
    
    func test___init_with_file_url() {
        XCTAssertEqual(
            AbsolutePath(URL(fileURLWithPath: "/path/to/something")),
            AbsolutePath("/path/to/something")
        )
    }
    
    func test___appending___can_add_arbitrary_number_of_components() {
        let path = AbsolutePath("/a/b")
        XCTAssertEqual(path.appending("c", "d", "e").pathString, "/a/b/c/d/e")
    }
    
    func test___appending___separates_every_component_by_slash_as_a_separator() {
        let path = AbsolutePath("/a/b")
        XCTAssertEqual(path.appending("c/d", "e/f").components, [
            "a", "b", "c", "d", "e", "f"
        ])
    }
    
    func test___validating() {
        assertThrows {
            try AbsolutePath.validating(string: "not/absolute/path")
        }
        
        assertThrows {
            try AbsolutePath.validating(string: "~/not/absolute/path")
        }
        
        assert {
            try AbsolutePath.validating(string: "/some/path")
        } equals: {
            AbsolutePath("/some/path")
        }
    }
    
    func test___standartization() {
        XCTAssertEqual(
            AbsolutePath("/some/path/../otherPath").standardized,
            AbsolutePath("/some/otherPath")
        )
    }
    
    func test___hasSuffix() {
        XCTAssertEqual(
            AbsolutePath("/a/b/c").hasSuffix("b/c"),
            true
        )
        XCTAssertEqual(
            AbsolutePath("/a/b/c").hasSuffix("b/"),
            false
        )
    }
    
    func test___contains() {
        XCTAssertEqual(
            AbsolutePath("/a/b/c").contains("/b/"),
            true
        )
        XCTAssertEqual(
            AbsolutePath("/a/b/c").contains("/c/"),
            false
        )
    }
    
    func test___hasPrefix() {
        XCTAssertEqual(
            AbsolutePath("/a/b/c").hasPrefix("/a/b"),
            true
        )
        XCTAssertEqual(
            AbsolutePath("/a/b/c").hasPrefix("a/b"),
            false
        )
    }
}
