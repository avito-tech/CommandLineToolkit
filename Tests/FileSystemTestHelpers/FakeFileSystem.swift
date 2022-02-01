import FileSystem
import Foundation
import PathLib

open class FakeFileSystem: FileSystem {
    public init(rootPath: AbsolutePath) {
        self.fakeCommonlyUsedPathsProvider = FakeCommonlyUsedPathsProvider(
            applicationsProvider: { _ in rootPath.appending("Applications") },
            cachesProvider: { _ in rootPath.appending("Library", "Caches") },
            libraryProvider: { _ in rootPath.appending("Library") },
            currentWorkingDirectoryProvider: { rootPath }
        )
    }
    
    public var fakeCommonlyUsedPathsProvider: FakeCommonlyUsedPathsProvider
    public var commonlyUsedPathsProvider: CommonlyUsedPathsProvider { fakeCommonlyUsedPathsProvider }
    
    public var fakeContentEnumerator: ((path: AbsolutePath, style: ContentEnumerationStyle)) -> FileSystemEnumerator = { args in
        FakeFileSystemEnumerator(path: args.path)
    }
    
    public func contentEnumerator(forPath path: AbsolutePath, style: ContentEnumerationStyle) -> FileSystemEnumerator {
        fakeContentEnumerator((path: path, style: style))
    }
    
    public var fakeGlobEnumerator: (GlobPattern) -> FileSystemEnumerator = { pattern in
        FakeFileSystemEnumerator(path: AbsolutePath(pattern.value))
    }
    
    public func glob(pattern: GlobPattern) -> FileSystemEnumerator {
        fakeGlobEnumerator(pattern)
    }
    
    public var onCreateDirectory: (AbsolutePath, Bool) throws -> () = { _, _ in }
    
    public func createDirectory(path: AbsolutePath, withIntermediateDirectories: Bool) throws {
        try onCreateDirectory(path, withIntermediateDirectories)
    }
    
    public var onCreateFile: (AbsolutePath, Data?) throws -> () = { _, _ in }
    
    public func createFile(path: AbsolutePath, data: Data?) throws {
        try onCreateFile(path, data)
    }
    
    public var onCopy: (AbsolutePath, AbsolutePath) throws -> () = { _, _ in }
    
    public func copy(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        try onCopy(source, destination)
    }
    
    public var onMove: (AbsolutePath, AbsolutePath) throws -> () = { _, _ in }

    public func move(source: AbsolutePath, destination: AbsolutePath, overwrite: Bool, ensureDirectoryExists: Bool) throws {
        try onMove(source, destination)
    }
    
    public var onDelete: (AbsolutePath) throws -> () = { _ in }
    
    public func delete(path: AbsolutePath, ignoreMissing: Bool) throws {
        try onDelete(path)
    }
    
    public var propertiesProvider: (AbsolutePath) -> FilePropertiesContainer = { _ in FakeFilePropertiesContainer() }
    public func properties(forFileAtPath path: AbsolutePath) -> FilePropertiesContainer {
        propertiesProvider(path)
    }
    
    public var fileSystemPropertiesProvider: (AbsolutePath) -> FileSystemPropertiesContainer = { _ in FakeFileSystemPropertiesContainer() }
    public func fileSystemProperties(forFileAtPath path: AbsolutePath) -> FileSystemPropertiesContainer {
        fileSystemPropertiesProvider(path)
    }
    
    public var onTouch: (AbsolutePath) throws -> () = { _ in }
    public func touch(path: AbsolutePath) throws {
        try onTouch(path)
    }
}
