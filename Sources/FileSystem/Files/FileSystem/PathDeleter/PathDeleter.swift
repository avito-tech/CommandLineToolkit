import PathLib

public protocol PathDeleter {
    /// Deletes file or directory (recursively)
    func delete(
        path: AbsolutePath,
        ignoreMissing: Bool
    ) throws
}

extension PathDeleter {
    public func delete(
        path: AbsolutePath
    ) throws {
        try delete(
            path: path,
            ignoreMissing: true
        )
    }
}
