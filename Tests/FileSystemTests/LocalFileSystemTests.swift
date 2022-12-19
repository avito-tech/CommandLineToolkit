import Foundation
import FileSystem
import XCTest

final class FilePropertiesProviderImplTests: XCTestCase {
    private let fileManager = FileManager()
    private lazy var tempFolder = createTempFolder()
    private let provider = FilePropertiesProviderImpl()
    
    func test___properties() throws {
        let path = try tempFolder.createFile(filename: "file")
        
        let properties = provider.properties(path: path)
        
        XCTAssertEqual(
            try properties.modificationDate.get(),
            try fileManager.attributesOfItem(atPath: path.pathString)[.modificationDate] as? Date
        )
    }
}
