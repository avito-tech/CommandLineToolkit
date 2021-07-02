import FileSystem
import Foundation
import TestHelpers
import Tmp
import XCTest

// swiftlint:disable multiple_closures_with_trailing_closure
final class GlobFileSystemEnumeratorTests: XCTestCase {
    lazy var tempFolder = assertDoesNotThrow { try TemporaryFolder() }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        try tempFolder.createFile(filename: "unrelated_file")
        try tempFolder.createFile(filename: "file.txt")
        try tempFolder.createFile(components: ["subfolder1"], filename: "file_in_subfolder1.txt")
        try tempFolder.createFile(components: ["subfolder1"], filename: "unrelated_file")
        try tempFolder.createFile(components: ["subfolder2"], filename: "file_in_subfolder2.txt")
    }

    func test___deep_glob() throws {
        let enumerator = GlobFileSystemEnumerator(
            pattern: .rootingAt(tempFolder.absolutePath).concat("/**/*.txt")
        )
        let paths = try enumerator.allPaths()
        
        assert {
            Set(paths)
        } equals: {
            Set([
                tempFolder.pathWith(components: ["file.txt"]),
                tempFolder.pathWith(components: ["subfolder1", "file_in_subfolder1.txt"]),
                tempFolder.pathWith(components: ["subfolder2", "file_in_subfolder2.txt"]),
            ])
        }
    }
    
    func test___shallow_glob() throws {
        let enumerator = GlobFileSystemEnumerator(
            pattern: .rootingAt(tempFolder.absolutePath).concat("/subfolder*")
        )
        let paths = try enumerator.allPaths()
        
        assert {
            Set(paths)
        } equals: {
            Set([
                tempFolder.pathWith(components: ["subfolder1"]),
                tempFolder.pathWith(components: ["subfolder2"]),
            ])
        }
    }
}
