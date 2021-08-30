import Foundation
import PathLib
import XCTest

class PathTests: XCTestCase {
    func test___init___removes_references_to_current_folder() {
        let path = AbsolutePath("/a/./b")
        XCTAssertEqual(path.components, ["a", "b"])
    }
    
    func test___appending___removes_references_to_current_folder() {
        let path = AbsolutePath("/a").appending("./b")
        XCTAssertEqual(path.components, ["a", "b"])
    }
    
    func test___extension___is_empty___if_path_doesnt_cointain_dots() {
        let path = AbsolutePath(components: ["file"])
        XCTAssertEqual(path.extension, "")
    }
    
    func test___extension() {
        let path = AbsolutePath(components: ["file.txt"])
        XCTAssertEqual(path.extension, "txt")
    }
    
    func test___extension___provides_last_extension___if_path_contains_multiple_extensions() {
        let path = AbsolutePath(components: ["file.aaa.txt"])
        XCTAssertEqual(path.extension, "txt")
    }
    
    func test___extension___is_empty___if_path_starts_with_dot() {
        let path = AbsolutePath(components: [".file"])
        XCTAssertEqual(path.extension, "")
    }
    
    func test___extension___provides_last_extension___if_path_contains_multiple_extensions___if_path_starts_with_dot_and_has_extensions() {
        let path = AbsolutePath(components: [".file.aaa.txt"])
        XCTAssertEqual(path.extension, "txt")
    }
    
    func test___removingExtension() {
        XCTAssertEqual(
            AbsolutePath("/path/to/file.txt").removingExtension,
            AbsolutePath("/path/to/file")
        )
        XCTAssertEqual(
            AbsolutePath("/path/to/file").removingExtension,
            AbsolutePath("/path/to/file")
        )
    }
}
