import Foundation

public struct LinkerSettings: Codable, Hashable {
    public let unsafeFlags: [String]
    
    public init(
        unsafeFlags: [String]
    ) {
        self.unsafeFlags = unsafeFlags
    }
    
    public var isDefined: Bool {
        !unsafeFlags.isEmpty
    }
}
