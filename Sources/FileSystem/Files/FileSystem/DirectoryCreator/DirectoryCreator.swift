import PathLib

public protocol DirectoryCreator {
    func createDirectory(
        path: AbsolutePath,
        withIntermediateDirectories: Bool
    ) throws
}

extension DirectoryCreator {
    public func createDirectory(
        path: AbsolutePath,
        withIntermediateDirectories: Bool = true
    ) throws {
        try createDirectory(
            path: path,
            withIntermediateDirectories: withIntermediateDirectories
        )
    }
    
    public func ensureDirectoryExists(
        path: AbsolutePath
    ) throws {
        try createDirectory(
            path: path,
            withIntermediateDirectories: true
        )
    }
}
