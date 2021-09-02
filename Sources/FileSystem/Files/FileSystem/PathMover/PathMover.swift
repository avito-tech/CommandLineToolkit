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
