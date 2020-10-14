import FileSystem
import Foundation
import PathLib
import TestHelpers
import TmpTestHelpers
import XCTest

final class DeepFileSystemEnumeratorTests: XCTestCase {
    private lazy var tempFolder = createTempFolder()
    
    func test___enumerating___complete() throws {
        let expectedPaths = try createTestDataForEnumeration(tempFolder: tempFolder)
        
        let enumerator = DeepFileSystemEnumerator(
            fileManager: FileManager(),
            path: tempFolder.absolutePath
        )
        
        var paths = Set<AbsolutePath>()
        try enumerator.each { (path: AbsolutePath) in
            paths.insert(path)
        }
        
        XCTAssertEqual(expectedPaths, paths)
    }
}
