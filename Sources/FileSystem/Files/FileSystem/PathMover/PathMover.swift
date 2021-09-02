import PathLib

public protocol PathMover {
    /// Moves `source` file to `destination` if `destination` it doesn't exist, throws otherwise
    func move(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws
}

extension PathMover {
    public func move(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool = true,
        ensureDirectoryExists: Bool = true
    ) throws {
        try move(
            source: source,
            destination: destination,
            overwrite: overwrite,
            ensureDirectoryExists: ensureDirectoryExists
        )
    }
}
