import Foundation

public struct FilePath: Hashable, Codable, CustomStringConvertible {
    public let root: PathRoot
    public let relativePath: String
    
    public var description: String { "\(root)/\(relativePath)" }
}
