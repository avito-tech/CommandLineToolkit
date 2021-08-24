import Foundation

extension Path {
    public init(_ fileUrl: URL) {
        self.init(fileUrl.path)
    }
    
    public init(_ path: String) {
        self.init(components: StringPathParsing.components(path: path))
    }
    
    public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
    
    // Example: PathClass.join("foo", "bar/baz", "qux")
    public static func join(_ components: StringRepresentable...) -> Self {
        Self(
            components: components.flatMap {
                StringPathParsing.components(path: $0.asString)
            }
        )
    }
    
    public func appending(components: [String]) -> Self {
        return Self(components: self.components + components)
    }
    
    public func appending(_ components: String...) -> Self {
        return appending(components: components)
    }
    
    public func appending(relativePath: RelativePath) -> Self {
        return Self(components: components + relativePath.components)
    }
    
    public func appending(component: String) -> Self {
        return Self(components: self.components + [component])
    }
    
    public func appending(extension: String) -> Self {
        let lastComponent = self.lastComponent
        return removingLastComponent.appending(component: lastComponent + "." + `extension`)
    }
    
    public var removingExtension: Self {
        let ext = `extension`
        if ext.isEmpty {
            return self
        }
        let lastComponent = self.lastComponent
        return removingLastComponent.appending(component: String(lastComponent.dropLast(ext.count + 1)))
    }
    
    public var removingLastComponent: Self {
        guard !components.isEmpty else {
            return self
        }
        return Self(components: Array(components.dropLast()))
    }
    
    public var lastComponent: String {
        guard let result = components.last else {
            return pathString
        }
        return result
    }
    
    /// Deletes the filename portion, beginning with the last slash `/' character to the end of string
    public var dirname: String {
        return removingLastComponent.pathString
    }
    
    /// Deletes any prefix ending with the last slash `/' character present in string (after firs stripping trailing slashes)
    public var basename: String {
        return lastComponent
    }
    
    /// Returns a suffix after the last dot symbol in basename. Returns empty string if there is no extension.
    /// Correctly handles hidden heading dot ("`.file`" - extension is empty).
    public var `extension`: String {
        let component = lastComponent
        guard let dotPosition = component.lastIndex(of: ".") else {
            return ""
        }
        if component.starts(with: "."), component.startIndex == dotPosition {
            return ""
        }
        return String(component.suffix(from: component.index(after: dotPosition)))
    }
    
    public func hasSuffix(_ suffix: String) -> Bool {
        pathString.hasSuffix(suffix)
    }
    
    public func contains(_ suffix: String) -> Bool {
        pathString.contains(suffix)
    }
    
    public func hasPrefix(_ prefix: String) -> Bool {
        pathString.hasPrefix(prefix)
    }
    
    // MARK: - Conformance to `Equatable`
    
    public static func == (left: Self, right: Self) -> Bool {
        return left.components == right.components
    }
    
    // MARK: - Conformance to `Hashable`
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(components)
    }
    
    // MARK: - Conformance to `Codable`
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self.init(
            try container.decode(String.self)
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(pathString)
    }
}
