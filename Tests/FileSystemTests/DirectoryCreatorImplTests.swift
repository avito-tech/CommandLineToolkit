import XCTest
import Foundation
import FileSystem
import TmpTestHelpers

final class DirectoryCreatorImplTests: XCTestCase {
    private let fileManager = FileManager()
    private lazy var tempFolder = createTempFolder()
    private let directoryCreator = DirectoryCreatorImpl(
        fileManager: FileManager(),
        filePropertiesProvider: FilePropertiesProviderImpl()
    )
    
    func test___creating_directory() throws {
        let path = tempFolder.pathWith(components: ["new_folder"])
        
        XCTAssertFalse(fileManager.fileExists(atPath: path.pathString))
        try directoryCreator.createDirectory(
            path: path,
            withIntermediateDirectories: true,
            ignoreExisting: false
        )

        var isDir: ObjCBool = false
        XCTAssertTrue(fileManager.fileExists(atPath: path.pathString, isDirectory: &isDir))
        XCTAssertTrue(isDir.boolValue)
    }
}
