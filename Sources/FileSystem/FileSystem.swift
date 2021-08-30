import Foundation
import PathLib

public enum ContentEnumerationStyle {
    case deep
    case shallow
}

public protocol FileSystem {
    func contentEnumerator(forPath: AbsolutePath, style: ContentEnumerationStyle) -> FileSystemEnumerator
    func glob(pattern: GlobPattern) -> FileSystemEnumerator
    
    func createDirectory(atPath: AbsolutePath, withIntermediateDirectories: Bool) throws
    func createFile(atPath: AbsolutePath, data: Data?) throws
    
    /// Copies `source` file if `destination` it doesn't exist, throws otherwise
    func copy(source: AbsolutePath, destination: AbsolutePath) throws
    
    /// Moves `source` file to `destination` if `destination` it doesn't exist, throws otherwise
    func move(source: AbsolutePath, destination: AbsolutePath) throws
    
    /// Deletes file or directory (recursively)
    func delete(path: AbsolutePath) throws
    
    func properties(forFileAtPath: AbsolutePath) -> FilePropertiesContainer
    var commonlyUsedPathsProvider: CommonlyUsedPathsProvider { get }
    
    func fileSystemProperties(forFileAtPath: AbsolutePath) -> FileSystemPropertiesContainer
}

extension FileSystem {
    public func exists(
        path: AbsolutePath,
        type: FileExistenceCheckType = .any
    ) -> Bool {
        return properties(forFileAtPath: path).exists(type: type)
    }
    
    public func delete(path: AbsolutePath, ignoreMissing: Bool) throws {
        if ignoreMissing {
            if exists(path: path) {
                try delete(path: path)
            } else {
                // ignore
            }
        } else {
            try delete(path: path)
        }
    }
    
    public func copy(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        try modify(
            destination: destination,
            shouldOverwrite: overwrite,
            shouldEnsureDirectoryExists: ensureDirectoryExists,
            modification: {
                try copy(source: source, destination: $0)
            }
        )
    }
    
    public func copy(
        contentsOfDirectory sourcePath: AbsolutePath,
        destinationDirectory destinationPath: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        if ensureDirectoryExists {
            try self.ensureDirectoryExists(path: sourcePath)
        }
        
        try contentEnumerator(forPath: sourcePath, style: .shallow).each { path in
            try copy(
                source: path,
                destination: destinationPath.appending(path.lastComponent),
                overwrite: overwrite,
                ensureDirectoryExists: false
            )
        }
    }
    
    public func move(
        source: AbsolutePath,
        destination: AbsolutePath,
        overwrite: Bool,
        ensureDirectoryExists: Bool
    ) throws {
        try modify(
            destination: destination,
            shouldOverwrite: overwrite,
            shouldEnsureDirectoryExists: ensureDirectoryExists,
            modification: {
                try move(source: source, destination: $0)
            }
        )
    }
    
    private func modify(
        destination: AbsolutePath,
        shouldOverwrite: Bool,
        shouldEnsureDirectoryExists: Bool,
        modification: (_ destination: AbsolutePath) throws -> ()
    ) throws {
        if shouldOverwrite {
            try deleteIfExists(path: destination)
        }
        
        if shouldEnsureDirectoryExists {
            try ensureDirectoryExists(
                path: destination.removingLastComponent
            )
        }
        
        try modification(destination)
    }
    
    private func deleteIfExists(path: AbsolutePath) throws {
        if exists(path: path) {
            try delete(path: path)
        }
    }
    
    public func ensureDirectoryExists(path: AbsolutePath) throws {
        let existence = existence(path: path)
        
        if existence.exists {
            if existence.isDirectory {
                // Already exists.
            } else {
                throw FileSystemError(
                    errorDescription: "Expected a directory, but found a file at path: \(path)"
                )
            }
        } else {
            try createDirectory(
                atPath: path,
                withIntermediateDirectories: true
            )
        }
    }
}

private struct FileSystemError: LocalizedError {
    let errorDescription: String?
}
