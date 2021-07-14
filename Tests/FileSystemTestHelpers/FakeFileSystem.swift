import FileSystem
import Foundation
import PathLib

open class FakeFileSystem: FileSystem {
    public init(rootPath: AbsolutePath) {
        self.fakeCommonlyUsedPathsProvider = FakeCommonlyUsedPathsProvider(
            applicationsProvider: { _ in rootPath.appending(components: ["Applications"]) },
            cachesProvider: { _ in rootPath.appending(components: ["Library", "Caches"]) },
            libraryProvider: { _ in rootPath.appending(component: "Library") },
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
    
    public func createDirectory(atPath: AbsolutePath, withIntermediateDirectories: Bool) throws {
        try onCreateDirectory(atPath, withIntermediateDirectories)
    }
    
    public var onCreateFile: (AbsolutePath, Data?) throws -> () = { _, _ in }
    
    public func createFile(atPath: AbsolutePath, data: Data?) throws {
        try onCreateFile(atPath, data)
    }
    
    public var onCopy: (AbsolutePath, AbsolutePath) throws -> () = { _, _ in }
    
    public func copy(source: AbsolutePath, destination: AbsolutePath) throws {
        try onCopy(source, destination)
    }
    
    public var onMove: (AbsolutePath, AbsolutePath) throws -> () = { _, _ in }
    
    public func move(source: AbsolutePath, destination: AbsolutePath) throws {
        try onMove(source, destination)
    }
    
    public var onDelete: (AbsolutePath) throws -> () = { _ in }
    
    public func delete(fileAtPath: AbsolutePath) throws {
        try onDelete(fileAtPath)
    }
    
    public var propertiesProvider: (AbsolutePath) -> FilePropertiesContainer = { _ in FakeFilePropertiesContainer() }
    public func properties(forFileAtPath path: AbsolutePath) -> FilePropertiesContainer {
        propertiesProvider(path)
    }
    
    public var fileSystemPropertiesProvider: (AbsolutePath) -> FileSystemPropertiesContainer = { _ in FakeFileSystemPropertiesContainer() }
    public func fileSystemProperties(forFileAtPath path: AbsolutePath) -> FileSystemPropertiesContainer {
        fileSystemPropertiesProvider(path)
    }
}
