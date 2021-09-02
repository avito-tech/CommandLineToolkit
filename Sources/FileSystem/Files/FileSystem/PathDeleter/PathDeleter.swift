import PathLib

public protocol PathDeleter {
    /// Deletes file or directory (recursively)
    func delete(path: AbsolutePath, ignoreMissing: Bool) throws
}
