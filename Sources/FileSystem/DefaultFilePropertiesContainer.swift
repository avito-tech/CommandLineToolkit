import Foundation
import PathLib

public final class DefaultFilePropertiesContainer: FilePropertiesContainer {
    private let path: AbsolutePath
    private let fileManager = FileManager()
    
    public init(path: AbsolutePath) {
        self.path = path
    }
    
    public func modificationDate() throws -> Date {
        let values = try path.fileUrl.resourceValues(forKeys: [.contentModificationDateKey])
        guard let value = values.contentModificationDate else {
            throw FilePropertiesContainerError.emptyValue(path, .contentModificationDateKey)
        }
        return value
    }
    
    public func set(modificationDate: Date) throws {
        var values = URLResourceValues()
        values.contentModificationDate = modificationDate
        var url = path.fileUrl
        try url.setResourceValues(values)
    }
    
    public func isExecutable() throws -> Bool {
        let values = try path.fileUrl.resourceValues(forKeys: [.isExecutableKey])
        guard let value = values.isExecutable else {
            throw FilePropertiesContainerError.emptyValue(path, .isExecutableKey)
        }
        return value
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
    
    public func exists() -> Bool {
        fileManager.fileExists(atPath: path.pathString)
    }
    
    public func isDirectory() throws -> Bool {
        let values = try path.fileUrl.resourceValues(forKeys: [.isDirectoryKey])
        guard let value = values.isDirectory else {
            throw FilePropertiesContainerError.emptyValue(path, .isDirectoryKey)
        }
        return value
    }
    
    public func isRegularFile() throws -> Bool {
        let values = try path.fileUrl.resourceValues(forKeys: [.isRegularFileKey])
        guard let value = values.isRegularFile else {
            throw FilePropertiesContainerError.emptyValue(path, .isRegularFileKey)
        }
        return value
    }
    
    public func isHidden() throws -> Bool {
        let values = try path.fileUrl.resourceValues(forKeys: [.isHiddenKey])
        guard let value = values.isHidden else {
            throw FilePropertiesContainerError.emptyValue(path, .isHiddenKey)
        }
        return value
    }
    
    public func size() throws -> Int {
        let values = try path.fileUrl.resourceValues(forKeys: [.fileSizeKey])
        guard let value = values.fileSize else {
            throw FilePropertiesContainerError.emptyValue(path, .fileSizeKey)
        }
        return value
    }
}
