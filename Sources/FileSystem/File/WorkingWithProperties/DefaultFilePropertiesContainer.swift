import Foundation
import PathLib
import Types
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public final class DefaultFilePropertiesContainer: FilePropertiesContainer {
    private let path: AbsolutePath
    private let fileManager = FileManager()
    
    public init(path: AbsolutePath) {
        self.path = path
    }

    public func snapshot() throws -> FilePropertiesSnapshot {
        var info = stat()
        guard stat(path.pathString, &info) == 0 else {
            throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: [NSFilePathErrorKey: path.pathString])
        }
        let kind: FilePropertiesSnapshot.Kind
        switch info.st_mode & mode_t(S_IFMT) {
        case mode_t(S_IFREG):
            kind = .regularFile
        case mode_t(S_IFDIR):
            kind = .directory
        default:
            kind = .other
        }
        #if canImport(Darwin)
        let modified = info.st_mtimespec
        #else
        let modified = info.st_mtim
        #endif
        return FilePropertiesSnapshot(
            kind: kind,
            modificationDate: Date(timeIntervalSince1970: Double(modified.tv_sec) + Double(modified.tv_nsec) / 1_000_000_000),
            size: Int(info.st_size)
        )
    }
    
    // MARK: - Resource values (read-write)
    
    public var modificationDate: ThrowingPropertyOf<Date> {
        resourceValueThrowingProperty(
            key: .contentModificationDateKey,
            keyPath: \.contentModificationDate
        )
    }
    
    // MARK: - Resource values (readonly)
    
    public var isExecutable: Bool {
        get throws {
            try gettableResourceValueThrowingProperty(
                key: .isExecutableKey,
                keyPath: \.isExecutable
            ).get()
        }
    }
    
    public var isDirectory: Bool {
        get throws {
            try gettableResourceValueThrowingProperty(
                key: .isDirectoryKey,
                keyPath: \.isDirectory
            ).get()
        }
    }
    
    public var isRegularFile: Bool {
        get throws {
            try gettableResourceValueThrowingProperty(
                key: .isRegularFileKey,
                keyPath: \.isRegularFile
            ).get()
        }
    }
    
    public var isHidden: Bool {
        get throws {
            try gettableResourceValueThrowingProperty(
                key: .isHiddenKey,
                keyPath: \.isHidden
            ).get()
        }
    }
    
    public var fileSize: Int {
        get throws {
            try gettableResourceValueThrowingProperty(
                key: .fileSizeKey,
                keyPath: \.fileSize
            ).get()
        }
    }
    
    public var totalFileAllocatedSize: Int {
        get throws {
            try gettableResourceValueThrowingProperty(
                key: .totalFileAllocatedSizeKey,
                keyPath: \.totalFileAllocatedSize
            ).get()
        }
    }
    
    public var isSymbolicLink: Bool {
        get throws {
            try gettableResourceValueThrowingProperty(
                key: .isSymbolicLinkKey,
                keyPath: \.isSymbolicLink
            ).get()
        }
    }
    
    // MARK: - Attributes
    
    public var permissions: ThrowingPropertyOf<Int16> {
        attributeThrowingProperty(
            key: .posixPermissions,
            rawType: NSNumber.self,
            readingTransform: { $0.int16Value }
        )
    }
    
    public var userId: ThrowingPropertyOf<Int> {
        attributeThrowingProperty(
            key: .ownerAccountID,
            rawType: NSNumber.self,
            readingTransform: { $0.intValue }
        )
    }
    
    // MARK: - Complex logic
    
    public var existence: FileExistence {
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
    
    public var isBrokenSymbolicLink: Bool {
        get throws {
            guard let symbolicLinkContainer = try symbolicLinkContainer() else {
                return false
            }
            
            return !symbolicLinkContainer.exists()
        }
    }
    
    public var isSymbolicLinkToDirectory: Bool {
        get throws {
            guard let symbolicLinkContainer = try symbolicLinkContainer(), symbolicLinkContainer.exists() else {
                return false
            }
            
            return try symbolicLinkContainer.isDirectory
        }
    }
    
    public var isSymbolicLinkToFile: Bool {
        get throws {
            guard let symbolicLinkContainer = try symbolicLinkContainer(), symbolicLinkContainer.exists() else {
                return false
            }
            
            return try symbolicLinkContainer.isRegularFile
        }
    }
    
    public var symbolicLinkPath: AbsolutePath? {
        get throws {
            guard try isSymbolicLink else { return nil }
            
            let symbolicLinkValue = try fileManager.destinationOfSymbolicLink(
                atPath: path.pathString
            )
            
            let symbolicLinkPath: AbsolutePath
            
            if RelativePath.isRelative(path: symbolicLinkValue) {
                symbolicLinkPath = path
                    .removingLastComponent
                    .appending(relativePath: RelativePath(symbolicLinkValue))
            } else if AbsolutePath.isAbsolute(path: symbolicLinkValue) {
                symbolicLinkPath = try AbsolutePath.validating(
                    string: symbolicLinkValue
                )
            } else {
                throw FilePropertiesContainerError.unrecognizedSymbolicLinkValue(
                    path: path,
                    symbolicLinkValue: symbolicLinkValue
                )
            }
            
            return symbolicLinkPath
        }
    }
    
    private func symbolicLinkContainer() throws -> FilePropertiesContainer? {
        guard let symbolicLinkPath = try symbolicLinkPath else {
            return nil
        }
        
        return DefaultFilePropertiesContainer(path: symbolicLinkPath)
    }
    
    // MARK: - Private
    
    private func gettableResourceValueThrowingProperty<T>(
        key: URLResourceKey,
        keyPath: KeyPath<URLResourceValues, T?>
    ) -> GettableThrowingPropertyOf<T> {
        GettableThrowingPropertyOf(
            throwingProperty: GettableResourceValueThrowingProperty<T>(
                path: path,
                key: key,
                keyPath: keyPath
            )
        )
    }
    
    private func resourceValueThrowingProperty<T>(
        key: URLResourceKey,
        keyPath: WritableKeyPath<URLResourceValues, T?>
    ) -> ThrowingPropertyOf<T> {
        ThrowingPropertyOf(
            throwingProperty: ResourceValueThrowingProperty<T>(
                path: path,
                key: key,
                keyPath: keyPath
            )
        )
    }
    
    private func attributeThrowingProperty<T, U>(
        key: FileAttributeKey,
        rawType: T.Type = T.self,
        readingTransform: @escaping (T) -> U
    ) -> ThrowingPropertyOf<U> {
        ThrowingPropertyOf(
            throwingProperty: AttributeThrowingProperty(
                fileManager: fileManager,
                path: path,
                key: key,
                readingTransform: readingTransform
            )
        )
    }
}

private final class AttributeThrowingProperty<T, U>: ThrowingProperty {
    typealias RawPropertyType = T
    typealias PropertyType = U
    
    private let fileManager: FileManager
    private let path: AbsolutePath
    private let key: FileAttributeKey
    private let readingTransform: (RawPropertyType) -> PropertyType
    
    init(
        fileManager: FileManager,
        path: AbsolutePath,
        key: FileAttributeKey,
        readingTransform: @escaping (RawPropertyType) -> PropertyType
    ) {
        self.fileManager = fileManager
        self.path = path
        self.key = key
        self.readingTransform = readingTransform
    }
    
    func get() throws -> PropertyType {
        let attributes = try fileManager.attributesOfItem(atPath: path.pathString)
        
        guard let value = attributes[key] else {
            throw FilePropertiesContainerError.emptyFileAttributeValue(
                path: path,
                key: key
            )
        }
        
        guard let number = value as? T else {
            throw FilePropertiesContainerError.mismatchingFileAttributeValueType(
                path: path,
                key: key,
                value: value,
                expectedType: T.self
            )
        }
        
        return readingTransform(number)
    }
    
    func set(_ value: PropertyType) throws {
        try fileManager.setAttributes([key: value], ofItemAtPath: path.pathString)
    }
}

private final class ResourceValueThrowingProperty<T>: GettableResourceValueThrowingProperty<T>, SettableThrowingProperty {
    private let path: AbsolutePath
    private let keyPath: WritableKeyPath<URLResourceValues, PropertyType?>
    
    init(
        path: AbsolutePath,
        key: URLResourceKey,
        keyPath: WritableKeyPath<URLResourceValues, PropertyType?>
    ) {
        self.path = path
        self.keyPath = keyPath
        
        super.init(
            path: path,
            key: key,
            keyPath: keyPath
        )
    }
    
    func set(_ value: PropertyType) throws {
        var values = URLResourceValues()
        
        values[keyPath: keyPath] = value
        
        var fileUrl = path.fileUrl
        
        try fileUrl.setResourceValues(values)
    }
}

private class GettableResourceValueThrowingProperty<T>: GettableThrowingProperty {
    typealias PropertyType = T
    
    private let path: AbsolutePath
    private let key: URLResourceKey
    private let keyPath: KeyPath<URLResourceValues, PropertyType?>
    
    init(
        path: AbsolutePath,
        key: URLResourceKey,
        keyPath: KeyPath<URLResourceValues, PropertyType?>
    ) {
        self.path = path
        self.key = key
        self.keyPath = keyPath
    }
    
    func get() throws -> PropertyType {
        let values = try path.fileUrl.resourceValues(forKeys: [key])
        guard let value = values[keyPath: keyPath] else {
            throw FilePropertiesContainerError.emptyValue(
                path: path,
                key: key
            )
        }
        return value
    }
}
