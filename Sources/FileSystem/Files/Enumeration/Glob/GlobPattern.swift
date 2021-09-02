import Foundation
import PathLib

public struct GlobPattern: Codable, Hashable {
    public let value: String
    
    public static func rootingAt(_ absolutePath: AbsolutePath) -> Self {
        Self(value: absolutePath.pathString)
    }
    
    public func concat(_ substring: String) -> Self {
        Self(value: value + substring)
    }
    
    private init(value: String) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    public struct GlobStartsWithNonAbsolutePathError: Error, CustomStringConvertible {
        let value: String
        
        public var description: String {
            "Glob '\(value)' does not start with absolute path"
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        guard value.hasPrefix("/") else {
            throw GlobStartsWithNonAbsolutePathError(value: value)
        }
        self.init(value: value)
    }
}
