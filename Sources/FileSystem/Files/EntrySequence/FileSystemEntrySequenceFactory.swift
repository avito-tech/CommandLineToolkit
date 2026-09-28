import PathLib

public protocol FileSystemEntrySequenceFactory {
    /// Includes the root entry. The synchronous predicate runs on the I/O
    /// queue before reading a directory; returning false prunes its children,
    /// but the directory itself is still returned. Symbolic links are not followed.
    func entries(
        at root: AbsolutePath,
        traversal: FileSystemTraversal,
        descendingInto: @escaping @Sendable (FileSystemEntry) -> Bool
    ) -> FileSystemEntrySequence
}

extension FileSystemEntrySequenceFactory {
    public func entries(at root: AbsolutePath, traversal: FileSystemTraversal = .recursive) -> FileSystemEntrySequence {
        entries(at: root, traversal: traversal, descendingInto: { _ in true })
    }
}

extension FileSystem {
    /// Compatibility backend for virtual filesystems: uses their existing
    /// properties and shallow enumerator rather than accessing the host disk.
    public func entries(
        at root: AbsolutePath,
        traversal: FileSystemTraversal,
        descendingInto: @escaping @Sendable (FileSystemEntry) -> Bool
    ) -> FileSystemEntrySequence {
        FileSystemEntrySequence {
            FileTreeCursor(
                root: root,
                traversal: traversal,
                descendingInto: descendingInto,
                metadata: { try self.properties(path: AbsolutePath($0)).snapshot(followSymbolicLinks: false) },
                children: { path, checkCancellation in
                    try self.contentEnumerator(forPath: AbsolutePath(path), style: .shallow).map {
                        try checkCancellation()
                        return $0.lastComponent
                    }
                }
            )
        }
    }
}
