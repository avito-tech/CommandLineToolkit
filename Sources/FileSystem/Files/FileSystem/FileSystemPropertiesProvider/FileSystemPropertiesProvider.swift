import PathLib

public protocol FileSystemPropertiesProvider {
    func fileSystemProperties(forFileAtPath: AbsolutePath) -> FileSystemPropertiesContainer
}

extension FileSystem {
    public func systemFreeSize(for path: AbsolutePath) throws -> Int64 {
        try fileSystemProperties(forFileAtPath: path).systemFreeSize()
    }
}
