import Darwin
import PathLib

/// Resolves all symbolic links, extra "/" characters, and references to /./
/// and /../ in the input.
/// Resolves both absolute and relative paths and return the absolute
/// pathname.  All components in the provided input must exist when realpath()
/// is called.

public final class RealpathProviderImpl: RealpathProvider {
    public struct RealpathError: Swift.Error, CustomStringConvertible {
        public let errno: Int32
        public let path: AbsolutePath

        public var description: String {
            """
            realpath returned error. path: '\(path)'. error: \(errno)
            """
        }
    }

    public func realpath(path: AbsolutePath) throws -> AbsolutePath {
        guard let result = Darwin.realpath(path.pathString, nil) else {
            throw RealpathError(
                errno: errno,
                path: path
            )
        }

        defer { free(result) }

        return AbsolutePath(String(cString: result))
    }
}
