import Foundation
import PathLib

public final class LocalFileSystem: FileSystem {
    private let fileSystemEnumeratorFactory: FileSystemEnumeratorFactory
    private let directoryCreator: DirectoryCreator
    private let fileCreator: FileCreator
    private let pathCopier: PathCopier
    private let pathMover: PathMover
    private let pathDeleter: PathDeleter
    private let filePropertiesProvider: FilePropertiesProvider
    private let fileSystemPropertiesProvider: FileSystemPropertiesProvider
    private let commonlyUsedPathsProviderFactory: CommonlyUsedPathsProviderFactory
    private let fileToucher: FileToucher
    private let pathLinker: PathLinker
    private let fileAppender: FileAppender
    
    public init(
        fileSystemEnumeratorFactory: FileSystemEnumeratorFactory,
        directoryCreator: DirectoryCreator,
        fileCreator: FileCreator,
        pathCopier: PathCopier,
        pathMover: PathMover,
        pathDeleter: PathDeleter,
        filePropertiesProvider: FilePropertiesProvider,
        fileSystemPropertiesProvider: FileSystemPropertiesProvider,
        commonlyUsedPathsProviderFactory: CommonlyUsedPathsProviderFactory,
        fileToucher: FileToucher,
        pathLinker: PathLinker,
        fileAppender: FileAppender
    ) {
        self.fileSystemEnumeratorFactory = fileSystemEnumeratorFactory
        self.directoryCreator = directoryCreator
        self.fileCreator = fileCreator
        self.pathCopier = pathCopier
        self.pathMover = pathMover
        self.pathDeleter = pathDeleter
        self.filePropertiesProvider = filePropertiesProvider
        self.fileSystemPropertiesProvider = fileSystemPropertiesProvider
        self.commonlyUsedPathsProviderFactory = commonlyUsedPathsProviderFactory
        self.fileToucher = fileToucher
        self.pathLinker = pathLinker
        self.fileAppender = fileAppender
    }
    
    public func symLink(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        try pathLinker.symLink(
            source: source,
            destination: destination,
            overwrite: overwrite,
            ensureDirectoryExists: ensureDirectoryExists
        )
    }
    
    public func copy(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        try pathCopier.copy(
            source: source,
            destination: destination,
            overwrite: overwrite,
            ensureDirectoryExists: ensureDirectoryExists
        )
    }
    
    public func move(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        try pathMover.move(
            source: source,
            destination: destination,
            overwrite: overwrite,
            ensureDirectoryExists: ensureDirectoryExists
        )
    }
    
    public func delete(
        path: AbsolutePath,
        ignoreMissing: Bool
    ) throws {
        try pathDeleter.delete(
            path: path,
            ignoreMissing: ignoreMissing
        )
    }
    
    public func createFile(
        path: AbsolutePath,
        data: Data?
    ) throws {
        try fileCreator.createFile(
            path: path,
            data: data
        )
    }
    
    public func createDirectory(
        path: AbsolutePath,
        withIntermediateDirectories: Bool
    ) throws {
        try directoryCreator.createDirectory(
            path: path,
            withIntermediateDirectories: withIntermediateDirectories
        )
    }
    
    public func properties(path: AbsolutePath) -> FilePropertiesContainer {
        return filePropertiesProvider.properties(path: path)
    }
    
    public var commonlyUsedPathsProvider: CommonlyUsedPathsProvider {
        commonlyUsedPathsProviderFactory.commonlyUsedPathsProvider
    }
    
    public func glob(pattern: GlobPattern) -> FileSystemEnumerator {
        fileSystemEnumeratorFactory.glob(pattern: pattern)
    }
    
    public func contentEnumerator(forPath: AbsolutePath, style: ContentEnumerationStyle) -> FileSystemEnumerator {
        fileSystemEnumeratorFactory.contentEnumerator(forPath: forPath, style: style)
    }
    
    public func touch(path: AbsolutePath) throws {
        try fileToucher.touch(path: path)
    }
    
    public func fileSystemProperties(forFileAtPath: AbsolutePath) -> FileSystemPropertiesContainer {
        fileSystemPropertiesProvider.fileSystemProperties(forFileAtPath: forFileAtPath)
    }
    
    public func appendToFile(path: AbsolutePath, data: Data) throws {
        try fileAppender.appendToFile(path: path, data: data)
    }
}
