import FileSystem
import XCTest
import TestHelpers

final class PathDeleterImplTests: XCTestCase {
    private lazy var fileManager = FileManager()
    private lazy var tempFolder = createTempFolder()
    private let pathDeleter = PathDeleterImpl(
        fileManager: FileManager(),
        filePropertiesProvider: FilePropertiesProviderImpl()
    )
    
    func test___delete___deletes_file___if_file_exists() {
        for ignoreMissing in [false, true] {
            assertDoesNotThrow {
                let path = try tempFolder.createFile(filename: "file")
                
                try pathDeleter.delete(path: path, ignoreMissing: ignoreMissing)
                XCTAssertFalse(fileManager.fileExists(atPath: path.pathString))
            }
        }
    }
    
    func test___delete___throws___if_file_doesnt_exists_and_ignore_missing_is_false() {
        let path = tempFolder.pathWith(components: ["non existing file"])
        
        XCTAssertFalse(fileManager.fileExists(atPath: path.pathString))
        assertThrows {
            try pathDeleter.delete(path: path, ignoreMissing: false)
        }
    }
    
    func test___delete___doesnt_throw___if_file_doesnt_exists_and_ignore_missing_is_true() {
        let path = tempFolder.pathWith(components: ["non existing file"])
        
        XCTAssertFalse(fileManager.fileExists(atPath: path.pathString))
        assertDoesNotThrow {
            try pathDeleter.delete(path: path, ignoreMissing: true)
        }
    }
}
