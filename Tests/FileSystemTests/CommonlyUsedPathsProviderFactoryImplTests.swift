import FileSystem
import XCTest

final class CommonlyUsedPathsProviderFactoryImplTests: XCTestCase {
    private let factory = CommonlyUsedPathsProviderFactoryImpl(
        fileManager: FileManager()
    )
    
    func test___commonlyUsedPathsProvider() {
        XCTAssertTrue(factory.commonlyUsedPathsProvider is DefaultCommonlyUsedPathsProvider)
    }
}
