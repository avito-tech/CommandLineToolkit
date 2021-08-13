import Foundation

public final class AbsolutePath: Path, Codable, Hashable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public let components: [String]
    
    public static let root = AbsolutePath(components: [])
    
    public static let home = AbsolutePath(NSHomeDirectory())
    
    public init(components: [String]) {
        self.components = components
    }
    
    public convenience init(fileUrl: URL) {
        self.init(fileUrl.path)
    }
    
    /// Returns an `AbsolutePath` only if `string` has a value that looks like an absolute path - begins with `/`.
    /// - Parameter string: String representation of absolute path.
    /// - Throws: Error when `string` doesn't seem to be an absolute path.
    /// - Returns:`AbsolutePath` with path parsed from `string`.
    public static func validating(string: String) throws -> AbsolutePath {
        struct ValidationError: Error, CustomStringConvertible {
            let string: String
            var description: String { "String '\(string)' does not appear to be an absolute path" }
        }
        guard isAbsolute(path: string) else { throw ValidationError(string: string) }
        return AbsolutePath(string)
    }
    
    public static func isAbsolute(path: String) -> Bool {
        path.hasPrefix("/")
    }
    
    public var pathString: String {
        return "/" + components.joined(separator: "/")
    }
    
    public var fileUrl: URL {
        return URL(fileURLWithPath: pathString)
    }
    
    public var standardized: AbsolutePath {
        AbsolutePath(fileUrl.standardized)
    }
    
    /// Returns true if current path is a child of given anchor path.
    /// Examples:
    ///     `/path/to/something` is subpath of `/path/to`.
    ///     `/path/to/something` is NOT subpath of `/path/to/something`.
    ///     `/path/of/something` is NOT subpath of `/path/to/`.
    public func isSubpathOf(anchorPath: AbsolutePath) -> Bool {
        guard components.count > anchorPath.components.count else {
            return false
        }
        let headComponents = Array(components.dropLast(components.count - anchorPath.components.count))
        return headComponents == anchorPath.components
    }
    
    /// Finds a `RelativePath` for this instance and a given anchor path.
    public func relativePath(anchorPath: AbsolutePath) -> RelativePath {
        let pathComponents = components
        let anchorComponents = anchorPath.components
        
        var componentsInCommon = 0
        for (c1, c2) in zip(pathComponents, anchorComponents) {
            if c1 != c2 {
                break
            }
            componentsInCommon += 1
        }
        
        let numberOfParentComponents = anchorComponents.count - componentsInCommon
        let numberOfPathComponents = pathComponents.count - componentsInCommon
        
        var relativeComponents = [String]()
        relativeComponents.reserveCapacity(numberOfParentComponents + numberOfPathComponents)
        for _ in 0..<numberOfParentComponents {
            relativeComponents.append("..")
        }
        relativeComponents.append(contentsOf: pathComponents[componentsInCommon..<pathComponents.count])
        
        return RelativePath(components: relativeComponents)
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
    
    public static func == (left: AbsolutePath, right: AbsolutePath) -> Bool {
        return left.components == right.components
    }
    
    public var isRoot: Bool {
        components.isEmpty
    }
}
