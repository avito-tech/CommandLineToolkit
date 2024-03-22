import Foundation

public struct TargetSpecificSettings: Codable, Hashable {
    public static let targetSpecificSettingsFile = "target.json"
    
    public let linkerSettings: LinkerSettings
    public let excludePaths: ExcludePaths
    public let swiftSettings: SwiftSettings
    
    public init(
        linkerSettings: LinkerSettings = .init(unsafeFlags: []),
        excludePaths: ExcludePaths = .empty,
        swiftSettings: SwiftSettings = .empty
    ) {
        self.linkerSettings = linkerSettings
        self.excludePaths = excludePaths
        self.swiftSettings = swiftSettings
    }
    
    public var isDefined: Bool {
        linkerSettings.isDefined || excludePaths.isDefined || swiftSettings.isDefined
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.linkerSettings = try container.decodeIfPresent(LinkerSettings.self, forKey: .linkerSettings) ?? LinkerSettings(unsafeFlags: [])
        self.swiftSettings = try container.decodeIfPresent(SwiftSettings.self, forKey: .swiftSettings) ?? .empty
        var exclude = try container.decodeIfPresent(ExcludePaths.self, forKey: .exclude) ?? .empty
        if self.linkerSettings.isDefined || exclude.isDefined || self.swiftSettings.isDefined {
            exclude.append(Self.targetSpecificSettingsFile)
        }
        self.excludePaths = exclude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        if linkerSettings.isDefined { try container.encode(linkerSettings, forKey: .linkerSettings) }
        if excludePaths.isDefined { try container.encode(excludePaths, forKey: .exclude) }
        if swiftSettings.isDefined { try container.encode(swiftSettings, forKey: .swiftSettings) }
    }
    
    private enum Keys: String, CodingKey {
        case linkerSettings
        case exclude
        case swiftSettings
    }
}
