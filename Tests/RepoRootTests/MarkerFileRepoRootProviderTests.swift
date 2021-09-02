import FileSystem
import FileSystemTestHelpers
import Foundation
import PathLib
import TestHelpers
import XCTest
import RepoRoot

final class MarkerFileRepoRootProviderTests: XCTestCase {
    lazy var rootPath = AbsolutePath("/some/root/path/")
    lazy var fileSystem = FakeFileSystem(rootPath: rootPath)
    lazy var markerFileRepoRootProvider = MarkerFileRepoRootProvider(
        fileExistenceChecker: fileSystem,
        markerFileName: ".reporoot",
        anyPathWithinRepo: rootPath
    )
    
    func test___repoRoot___returns_path_to_reporoot_file_folder___if_reporoot_file_is_located() {
        fileSystem.propertiesProvider = { path in
            FakeFilePropertiesContainer(
                pathExists: path == self.rootPath.removingLastComponent.appending(".reporoot")
            )
        }
        
        let repoRoot = assertDoesNotThrow {
            try markerFileRepoRootProvider.repoRoot()
        }
        XCTAssertEqual(repoRoot, rootPath.removingLastComponent)
    }
    
    func test___repoRoot___throws___when_reporoot_file_is_not_located() {
        fileSystem.propertiesProvider = { _ in FakeFilePropertiesContainer(pathExists: false) }
        
        assertThrows {
            try markerFileRepoRootProvider.repoRoot()
        }
    }
}
