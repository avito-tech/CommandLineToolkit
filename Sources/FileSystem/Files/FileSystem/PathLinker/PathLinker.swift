import PathLib

public protocol PathLinker {
    func symLink(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws
}

public extension PathLinker {
    func symLink(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool = true,
        ensureDirectoryExists: Bool = true
    ) throws {
        try symLink(
            source: source,
            destination: destination,
            overwrite: overwrite,
            ensureDirectoryExists: overwrite
        )
    }
}
