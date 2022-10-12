import Foundation
import PathLib

public final class DefaultFilePropertiesContainer: FilePropertiesContainer {
    private let path: AbsolutePath
    private let fileManager = FileManager()
    
    public init(path: AbsolutePath) {
        self.path = path
    }
    
    public func modificationDate() throws -> Date {
        try resourceValue(
            key: .contentModificationDateKey,
            keyPath: \.contentModificationDate
        )
    }
    
    public func set(modificationDate: Date) throws {
        var values = URLResourceValues()
        values.contentModificationDate = modificationDate
        var url = path.fileUrl
        try url.setResourceValues(values)
    }
    
    public func isExecutable() throws -> Bool {
        try resourceValue(
            key: .isExecutableKey,
            keyPath: \.isExecutable
        )
    }
    
    public func permissions() throws -> Int16 {
        let attributes = try fileManager.attributesOfItem(atPath: path.pathString)
        guard let value = attributes[.posixPermissions], let number = value as? NSNumber else {
            throw FilePropertiesContainerError.emptyFileAttributeValue(path, .posixPermissions)
        }
        return number.int16Value
    }
    
    public func set(permissions: Int16) throws {
        try fileManager.setAttributes([.posixPermissions: permissions], ofItemAtPath: path.pathString)
    }
    
    public func existence() -> FileExistence {
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: path.pathString, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return .isDirectory
            } else {
                return .isFile
            }
        } else {
            return .doesntExist
        }
    }
    
    public func isDirectory() throws -> Bool {
        try resourceValue(
            key: .isDirectoryKey,
            keyPath: \.isDirectory
        )
    }
    
    public func isRegularFile() throws -> Bool {
        try resourceValue(
            key: .isRegularFileKey,
            keyPath: \.isRegularFile
        )
    }
    
    public func isHidden() throws -> Bool {
        try resourceValue(
            key: .isHiddenKey,
            keyPath: \.isHidden
        )
    }
    
    public func fileSize() throws -> Int {
        try resourceValue(
            key: .fileSizeKey,
            keyPath: \.fileSize
        )
    }
    
    public func totalFileAllocatedSize() throws -> Int {
        try resourceValue(
            key: .totalFileAllocatedSizeKey,
            keyPath: \.totalFileAllocatedSize
        )
    }
    
    public func isSymbolicLink() throws -> Bool {
        try resourceValue(
            key: .isSymbolicLinkKey,
            keyPath: \.isSymbolicLink
        )
    }
    
    public func isBrokenSymbolicLink() throws -> Bool {
        guard let symbolicLinkContainer = try symbolicLinkContainer() else {
            return false
        }
        return !symbolicLinkContainer.exists()
    }
    
    public func isSymbolicLinkToDirectory() throws -> Bool {
        guard
            let symbolicLinkContainer = try symbolicLinkContainer(),
            symbolicLinkContainer.exists() else {
            return false
        }
        return try symbolicLinkContainer.isDirectory()
    }
    
    public func isSymbolicLinkToFile() throws -> Bool {
        guard
            let symbolicLinkContainer = try symbolicLinkContainer(),
            symbolicLinkContainer.exists() else {
            return false
        }
        return try symbolicLinkContainer.isRegularFile()
    }
    
    public func symbolicLinkPath() throws -> AbsolutePath? {
        guard try isSymbolicLink() else { return nil }
        let symbolicLinkValue = try fileManager.destinationOfSymbolicLink(atPath: path.pathString)
        let symbolicLinkPath: AbsolutePath
        if RelativePath.isRelative(path: symbolicLinkValue) {
            symbolicLinkPath = path.removingLastComponent.appending(relativePath: RelativePath(symbolicLinkValue))
        } else if AbsolutePath.isAbsolute(path: symbolicLinkValue) {
            symbolicLinkPath = try AbsolutePath.validating(string: symbolicLinkValue)
        } else {
            throw FilePropertiesContainerError.unrecognizedSymblicLinkValue(path, symbolicLinkValue)
        }
        return symbolicLinkPath
    }
    
    private func symbolicLinkContainer() throws -> FilePropertiesContainer? {
        guard let symbolicLinkPath = try symbolicLinkPath() else {
            return nil
        }
        return DefaultFilePropertiesContainer(path: symbolicLinkPath)
    }
    
    private func resourceValue<T>(
        key: URLResourceKey,
        keyPath: KeyPath<URLResourceValues, T?>
    ) throws -> T {
        let values = try path.fileUrl.resourceValues(forKeys: [key])
        guard let value = values[keyPath: keyPath] else {
            throw FilePropertiesContainerError.emptyValue(path, key)
        }
        return value
    }
}
