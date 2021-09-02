import PathLib

public final class FilePropertiesProviderImpl: FilePropertiesProvider {
    public init() {
    }
    
    public func properties(forFileAtPath path: AbsolutePath) -> FilePropertiesContainer {
        return DefaultFilePropertiesContainer(path: path)
    }
}
