import PathLib

public protocol DirectoryCreator {
    func createDirectory(
        path: AbsolutePath,
        withIntermediateDirectories: Bool,
        ignoreExisting: Bool
    ) throws
}

extension DirectoryCreator {
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
