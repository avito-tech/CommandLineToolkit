import Foundation

/// Platform that package supports
public struct PackagePlatform: Codable, Hashable {
    
    /// Name, e.g. "macOS"
    public let name: String
    
    /// Version, e.g. "10.15"
    public let version: String
    
    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
}
