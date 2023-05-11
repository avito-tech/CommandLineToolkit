#if os(macOS)
import FileSystem
import PathLib
import TestHelpers
import XCTest

final class AppleCommonlyUsedPathsProviderTests: XCTestCase {
    private lazy var fileManager = FileManager()
    private lazy var defaultCommonlyUsedPathsProvider = AppleCommonlyUsedPathsProvider()
    
    func test___applications() {
        XCTAssertEqual(
            try defaultCommonlyUsedPathsProvider.applications(inDomain: .local, create: false),
            AbsolutePath("/Applications")
        )
    }
    
    func test___library() {
        XCTAssertEqual(
            try defaultCommonlyUsedPathsProvider.library(inDomain: .user, create: false).fileUrl,
            try fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        )
    }
    
    func test___caches() {
        XCTAssertEqual(
            try defaultCommonlyUsedPathsProvider.caches(inDomain: .user, create: false).fileUrl,
            try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        )
    }
}
#endif
