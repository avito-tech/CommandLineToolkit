import FileSystem
import Foundation
import PathLib
import TestHelpers
import Tmp
import XCTest

final class DefaultFilePropertiesContainerTests: XCTestCase {
    private lazy var temporaryFile = assertDoesNotThrow { try TemporaryFile(deleteOnDealloc: true) }
    private lazy var temporaryFolder = assertDoesNotThrow { try TemporaryFolder(deleteOnDealloc: true) }
    private lazy var filePropertiesContainer = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath)
    
    func test___modificationDate() {
        XCTAssertEqual(
            try filePropertiesContainer.modificationDate(),
            try temporaryFile.absolutePath.fileUrl.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        )
    }
    
    func test___setting_modificationDate() throws {
        let date = Date(timeIntervalSince1970: 1000)
        
        try filePropertiesContainer.set(modificationDate: date)
        
        XCTAssertEqual(
            try temporaryFile.absolutePath.fileUrl.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate,
            date
        )
    }
    
    func test___properties_for_nonexisting_file() {
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath.appending("nonexisting"))
        assertThrows {
            try properties.modificationDate()
        }
    }
    
    func test___is_executable___when_not_executable() throws {
        try FileManager().setAttributes(
            [.posixPermissions: 700],
            ofItemAtPath: temporaryFile.absolutePath.pathString
        )
        
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath)
        XCTAssertFalse(try properties.isExecutable())
    }
    
    func test___is_executable___when_executable() throws {
        try FileManager().setAttributes(
            [.posixPermissions: 707],
            ofItemAtPath: temporaryFile.absolutePath.pathString
        )
        
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath)
        XCTAssertTrue(try properties.isExecutable())
    }
    
    func test___modifying_permissions() throws {
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath)
        
        let originalPermissions = try properties.permissions()
        
        try properties.set(permissions: 0o707)
        XCTAssertEqual(try properties.permissions(), 0o707)
        
        try properties.set(permissions: originalPermissions)
        XCTAssertEqual(try properties.permissions(), originalPermissions)
    }
    
    func test___exists___when_exists() throws {
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath)
        XCTAssertTrue(properties.exists())
    }
    
    func test___not_exists___when_not_exists() throws {
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath.appending("nonexisting"))
        XCTAssertFalse(properties.exists())
    }
    
    func test___is_directory___for_directory() throws {
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath.removingLastComponent)
        XCTAssertTrue(try properties.isDirectory())
    }
    
    func test___is_not_directory___for_non_directories() throws {
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath)
        XCTAssertFalse(try properties.isDirectory())
    }
    
    func test___size() throws {
        temporaryFile.fileHandleForWriting.write(Data([0x00, 0x01, 0x02]))
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath)
        XCTAssertEqual(try properties.fileSize(), 3)
    }
    
    func test___totalFileAllocatedSize() throws {
        temporaryFile.fileHandleForWriting.write(Data([0x00, 0x01, 0x02]))
        let properties = DefaultFilePropertiesContainer(path: temporaryFile.absolutePath)
        XCTAssertEqual(try properties.totalFileAllocatedSize(), 4096)
    }
    
    func test___symbolic_link___for_absolute_directory() throws {
        let symbolicLinkPath = try temporaryFolder.createSymbolicLink(
            at: "symbolic_link",
            destination: AbsolutePath("/System")
        )
        let properties = DefaultFilePropertiesContainer(path: symbolicLinkPath)
        XCTAssertTrue(try properties.isSymbolicLink())
        XCTAssertFalse(try properties.isBrokenSymbolicLink())
        XCTAssertTrue(try properties.isSymbolicLinkToDirectory())
        XCTAssertFalse(try properties.isSymbolicLinkToFile())
        XCTAssertEqual(try properties.symbolicLinkPath(), "/System")
    }
    
    func test___symbolic_link___for_relative_directory() throws {
        let directoryName = "directory"
        let directoryPath = try temporaryFolder.createDirectory(components: [directoryName])
        let symbolicLinkPath = try temporaryFolder.createSymbolicLink(
            at: "directory_link",
            destination: RelativePath(directoryName)
        )
        let properties = DefaultFilePropertiesContainer(path: symbolicLinkPath)
        XCTAssertTrue(try properties.isSymbolicLink())
        XCTAssertFalse(try properties.isBrokenSymbolicLink())
        XCTAssertTrue(try properties.isSymbolicLinkToDirectory())
        XCTAssertFalse(try properties.isSymbolicLinkToFile())
        XCTAssertEqual(try properties.symbolicLinkPath(), directoryPath)
    }
    
    func test___symbolic_link___for_relative_file() throws {
        let filename = "file"
        let filePath = try temporaryFolder.createFile(filename: filename)
        let symbolicLinkPath = try temporaryFolder.createSymbolicLink(
            at: "file_link",
            destination: RelativePath(filename)
        )
        let properties = DefaultFilePropertiesContainer(path: symbolicLinkPath)
        XCTAssertTrue(try properties.isSymbolicLink())
        XCTAssertFalse(try properties.isBrokenSymbolicLink())
        XCTAssertFalse(try properties.isSymbolicLinkToDirectory())
        XCTAssertTrue(try properties.isSymbolicLinkToFile())
        XCTAssertEqual(try properties.symbolicLinkPath(), filePath)
    }
    
    func test___not_symbolic_link() throws {
        let filePath = try temporaryFolder.createFile(filename: "file")
        let properties = DefaultFilePropertiesContainer(path: filePath)
        XCTAssertFalse(try properties.isSymbolicLink())
        XCTAssertFalse(try properties.isBrokenSymbolicLink())
        XCTAssertFalse(try properties.isSymbolicLinkToDirectory())
        XCTAssertFalse(try properties.isSymbolicLinkToFile())
        XCTAssertEqual(try properties.symbolicLinkPath(), nil)
    }
    
    func test___broken_symbolic_link() throws {
        let symbolicLinkPath = try temporaryFolder.createSymbolicLink(
            at: "broken_link",
            destination: RelativePath("nonexisting")
        )
        let properties = DefaultFilePropertiesContainer(path: symbolicLinkPath)
        XCTAssertTrue(try properties.isSymbolicLink())
        XCTAssertTrue(try properties.isBrokenSymbolicLink())
        XCTAssertFalse(try properties.isSymbolicLinkToDirectory())
        XCTAssertFalse(try properties.isSymbolicLinkToFile())
        XCTAssertEqual(try properties.symbolicLinkPath(), temporaryFolder.absolutePath.appending("nonexisting"))
    }
    
}
