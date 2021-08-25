import Foundation

public final class RelativePath:
    Path,
    Codable,
    Hashable,
    ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral
{
    public let components: [String] // source value
    public let pathString: String // precomputed value
    
    public static let current = RelativePath(components: [String]())

    /// Builds a relative paths from given components. If components is empty, relative path will be equal to the current directory (`./`).
    public init<S: StringProtocol>(components: [S]) {
        self.components = StringPathParsing.slashSeparatedComponents(paths: components)
        self.pathString = Self.pathString(components: self.components)
    }
    
    /// Returns a `RelativePath` only if `string` has a value that looks like a relative path - does not begin with `/`
    /// - Parameter string: String representation of relative path.
    /// - Throws: Error when `string` doesn't seem to be a relative path
    /// - Returns:`RelativePath` with path parsed from `string`.
    public static func validating<S: StringProtocol>(string: S) throws -> RelativePath {
        guard isRelative(path: string) else {
            throw ValidationError(string: string)
        }
        return RelativePath(string)
    }
    
    public static func isRelative<S: StringProtocol>(path: S) -> Bool {
        !path.hasPrefix("/")
    }
    
    private static func pathString<S: StringProtocol>(components: [S]) -> String {
        guard !components.isEmpty else {
            return "./"
        }
        
        return components.joined(separator: "/")
    }
    
    private struct ValidationError<S: StringProtocol>: Error, CustomStringConvertible {
        let string: S
        var description: String { "String '\(string)' does not appear to be a relative path" }
    }
}
