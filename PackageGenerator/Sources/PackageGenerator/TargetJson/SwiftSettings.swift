import Foundation

public struct SwiftSettings: Hashable {
    public let values: [SwiftSetting]
    public var isDefined: Bool {
        !values.isEmpty
    }
    
    func merging(other: SwiftSettings?) -> SwiftSettings {
        let otherValues = other?.values ?? []
        return SwiftSettings(values: otherValues + values)
    }
    
    public static let empty = SwiftSettings(values: [])
}

extension SwiftSettings: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        values = try container.decode([SwiftSetting].self)
    }
    
    public func encode(to encoder: Encoder) throws {
        guard isDefined else { return }
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }
}

extension SwiftSettings: Sequence {
    public func makeIterator() -> [SwiftSetting].Iterator {
        values.makeIterator()
    }
}

public enum SwiftSetting: Hashable, Codable {
    case define(name: String)
    case unsafeFlags(flags: [String])
    case enableExperimentalFeature(name: String)
    case enableUpcomingFeature(name: String)
    case interoperabilityMode(mode: SwiftInteroperabilityMode)
}

public enum SwiftInteroperabilityMode: String, Codable {
    case C
    case CXX
}
