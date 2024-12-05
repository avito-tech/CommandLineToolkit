import Foundation

public struct ImageError: Error, CustomStringConvertible {
    public init(_ description: String) {
        self.description = description
    }
    public let description: String
}
