import Foundation

public final class RelativePath: Path, Codable, Hashable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public let components: [String]
    
    public static let current = RelativePath(components: [])

    /// Builds a relative paths from given components. If components is empty, relative path will be equal to the current directory (`./`).
    public init(components: [String]) {
        self.components = components
    }
    
    /// Returns a `RelativePath` only if `string` has a value that looks like a relative path - does not begin with `/`
    /// - Parameter string: String representation of relative path.
    /// - Throws: Error when `string` doesn't seem to be a relative path
    /// - Returns:`RelativePath` with path parsed from `string`.
    public static func validating(string: String) throws -> RelativePath {
        struct ValidationError: Error, CustomStringConvertible {
            let string: String
            var description: String { "String '\(string)' does not appear to be a relative path" }
        }
        guard isRelative(path: string) else { throw ValidationError(string: string) }
        return RelativePath(string)
    }
    
    public static func isRelative(path: String) -> Bool {
        !path.hasPrefix("/")
    }
    
    public var pathString: String {
        guard !components.isEmpty else {
            return "./"
        }
        
        return components.joined(separator: "/")
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        self.components = StringPathParsing.components(path: stringValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(pathString)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(components)
    }
    
    public static func == (left: RelativePath, right: RelativePath) -> Bool {
        return left.components == right.components
    }
}
