import Foundation

extension Path {
    public init(_ fileUrl: URL) {
        self.init(fileUrl.path)
    }
    
    public init<S: StringProtocol>(_ path: S) {
        self.init(components: [path])
    }
    
    public func appending<S: StringProtocol>(components: [S]) -> Self {
        return Self(
            components: self.components + components.map { String($0) }
        )
    }
    
    public func appending<S: StringProtocol>(_ components: S...) -> Self {
        return appending(components: components)
    }
    
    public func appending(relativePath: RelativePath) -> Self {
        return Self(components: components + relativePath.components)
    }
    
    public func appending<S: StringProtocol>(extension: S) -> Self {
        let lastComponent = self.lastComponent
        return removingLastComponent.appending(lastComponent + "." + `extension`)
    }
    
    public var removingExtension: Self {
        let ext = `extension`
        if ext.isEmpty {
            return self
        }
        let lastComponent = self.lastComponent
        return removingLastComponent.appending(lastComponent.dropLast(ext.count + 1))
    }
    
    public var removingLastComponent: Self {
        guard !components.isEmpty else {
            return self
        }
        return Self(components: components.dropLast())
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
    
    public func hasSuffix<S: StringProtocol>(_ suffix: S) -> Bool {
        pathString.hasSuffix(suffix)
    }
    
    public func contains<S: StringProtocol>(_ string: S) -> Bool {
        pathString.contains(string)
    }
    
    public func hasPrefix<S: StringProtocol>(_ prefix: S) -> Bool {
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
    
    // MARK: - Conformance to `ExpressibleByArrayLiteral`
    
    public init(arrayLiteral elements: String...) {
        self.init(components: elements)
    }
    
    // MARK: - Conformance to `ExpressibleByStringLiteral`
    
    public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
}
