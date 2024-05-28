import Foundation
import PathLib

public protocol FileSystemEnumerator {
    func each(iterator: (AbsolutePath) throws -> ()) throws
}

public extension FileSystemEnumerator {
    func allPaths() throws -> [AbsolutePath] {
        var paths = [AbsolutePath]()
        try each { path in
            paths.append(path)
        }
        return paths
    }
    
    func map<T>(transform: (AbsolutePath) throws -> T) throws -> [T] {
        var paths = [T]()
        try each { path in
            paths.append(try transform(path))
        }
        return paths
    }
    
    func filter(isIncluded: (AbsolutePath) throws -> Bool) throws -> [AbsolutePath] {
        var paths = [AbsolutePath]()
        try each { path in
            if try isIncluded(path) {
                paths.append(path)
            }
        }
        return paths
    }

    func contains(_ predicate: (AbsolutePath) throws -> Bool) throws -> Bool {
        do {
            try each { path in
                if try predicate(path) {
                    throw EarlyExitError()
                }
            }
        } catch is EarlyExitError {
            return true
        } catch {
            throw error
        }
        return false
    }

    func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, AbsolutePath) throws -> T) throws -> T {
        var result = initialResult
        try each { path in
            result = try nextPartialResult(result, path)
        }
        return result
    }
}

private struct EarlyExitError: Error {}
