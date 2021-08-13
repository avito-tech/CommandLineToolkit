import Foundation
import PathLib
import TestHelpers
import Tmp
import XCTest

final class TemporaryStuffTests: XCTestCase {
    func testCreatingTemporaryStuff() throws {
        assertDoesNotThrow {
            try TemporaryFolder()
        }
    }
    
    func testCreatingFolders() throws {
        let tempFolder = try TemporaryFolder()
        let path = try tempFolder.createDirectory(components: ["a", "b", "c"])
        var isDir: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: path.pathString, isDirectory: &isDir))
        XCTAssertTrue(isDir.boolValue)
    }
    
    func testCreaintFile() throws {
        let tempFolder = try TemporaryFolder()
        let contents = "hello"
        let path = try tempFolder.createFile(components: ["a", "b"], filename: "file.txt", contents: contents.data(using: .utf8))
        
        var isDir: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: path.pathString, isDirectory: &isDir))
        XCTAssertFalse(isDir.boolValue)
        
        let actualContents = try String(contentsOfFile: path.pathString)
        XCTAssertEqual(contents, actualContents)
    }
}
