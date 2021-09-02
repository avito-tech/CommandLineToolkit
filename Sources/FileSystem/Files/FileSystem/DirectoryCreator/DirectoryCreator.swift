import PathLib

public protocol DirectoryCreator {
    func createDirectory(
        path: AbsolutePath,
        withIntermediateDirectories: Bool,
        ignoreExisting: Bool
    ) throws
}

extension DirectoryCreator {
    public func createDirectory(
        path: AbsolutePath,
        withIntermediateDirectories: Bool = true,
        ignoreExisting: Bool = true
    ) throws {
        try createDirectory(
            path: path,
            withIntermediateDirectories: withIntermediateDirectories,
            ignoreExisting: ignoreExisting
        )
    }
    
    public func ensureDirectoryExists(
        path: AbsolutePath
    ) throws {
        try createDirectory(
            path: path,
            withIntermediateDirectories: true,
            ignoreExisting: true
        )
    }
}
