import Foundation

public final class AbsolutePath:
    Path,
    Codable,
    Hashable,
    ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral
{
    // MARK: - Static interface
    
    public static let root = AbsolutePath(components: [String]())
    public static let home = AbsolutePath(NSHomeDirectory())
    
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
    
    // MARK: - Instance members
    
    public let components: [String] // source value
    public let pathString: String // precomputed value
    
    // MARK: - Initializers members
    
    public init<S: StringProtocol>(components: [S]) {
        self.components = StringPathParsing.slashSeparatedComponents(paths: components)
        self.pathString = Self.pathString(components: self.components)
    }
    
    // MARK: - Instance interface
    
    public var isRoot: Bool {
        components.isEmpty
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
        return zip(anchorPath.components, components.prefix(upTo: anchorPath.components.count)).allSatisfy { lhs, rhs in
            lhs == rhs
        }
    }
    
    /// Finds a `RelativePath` for this instance and a given anchor path.
    public func relativePath(anchorPath: AbsolutePath) -> RelativePath {
        let pathComponents = components
        let anchorComponents = anchorPath.components
        
        var componentsInCommon = 0
        for (pathComponent, anchorComponent) in zip(pathComponents, anchorComponents) {
            if pathComponent != anchorComponent {
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
    
    // MARK: - Conformance to `ExpressibleByStringLiteral`
    
    public typealias StringLiteralType = String
    
    // MARK: - Private
    
    private static func pathString<S: StringProtocol>(components: [S]) -> String {
        "/" + components.joined(separator: "/")
    }
}
