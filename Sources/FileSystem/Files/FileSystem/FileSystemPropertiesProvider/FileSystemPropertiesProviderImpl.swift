import PathLib

public final class FileSystemPropertiesProviderImpl: FileSystemPropertiesProvider {
    public init() {
    }
    
    public func fileSystemProperties(forFileAtPath path: AbsolutePath) -> FileSystemPropertiesContainer {
        return DefaultFileSystemPropertiesContainer(path: path)
    }
}
