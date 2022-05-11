import Foundation

public enum PathRoot: String, Hashable, Codable, CustomStringConvertible {
    case repoRoot
    case currentPackage
    
    public var description: String { rawValue }
}
