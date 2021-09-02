import PathLib

public protocol PathCopier {
    func copy(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws
}

extension PathCopier {
    public func copy(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool = true,
        ensureDirectoryExists: Bool = true
    ) throws {
        try copy(
            source: source,
            destination: destination,
            overwrite: overwrite,
            ensureDirectoryExists: ensureDirectoryExists
        )
    }
}
