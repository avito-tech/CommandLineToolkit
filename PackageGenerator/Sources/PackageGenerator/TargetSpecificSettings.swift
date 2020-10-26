import Foundation

public struct TargetSpecificSettings: Codable, Hashable {
    public let linkerSettings: LinkerSettings
    
    public init(
        linkerSettings: LinkerSettings
    ) {
        self.linkerSettings = linkerSettings
    }
}

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

public extension LinkerSettings {
    var statements: [String] {
        var result = [String]()
        if !unsafeFlags.isEmpty {
            result.append(".unsafeFlags([" + unsafeFlags.map { "\"\($0)\"" }.joined(separator: ", ") + "])")
        }
        return result
    }
}
