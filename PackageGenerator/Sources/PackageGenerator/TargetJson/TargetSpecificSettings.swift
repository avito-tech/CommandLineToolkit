import Foundation

public struct TargetSpecificSettings: Codable, Hashable {
    public static let targetSpecificSettingsFile = "target.json"
    
    public let linkerSettings: LinkerSettings
    public let excludePaths: ExcludePaths
    
    public init(
        linkerSettings: LinkerSettings,
        excludePaths: ExcludePaths = .empty
    ) {
        self.linkerSettings = linkerSettings
        self.excludePaths = excludePaths
    }
    
    public var isDefined: Bool {
        linkerSettings.isDefined || excludePaths.isDefined
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.linkerSettings = try container.decodeIfPresent(LinkerSettings.self, forKey: .linkerSettings) ?? LinkerSettings(unsafeFlags: [])
        var exclude = try container.decodeIfPresent(ExcludePaths.self, forKey: .exclude) ?? .empty
        if self.linkerSettings.isDefined || exclude.isDefined {
            exclude.append(Self.targetSpecificSettingsFile)
        }
        self.excludePaths = exclude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(linkerSettings, forKey: .linkerSettings)
        try container.encode(excludePaths, forKey: .exclude)
    }
    
    private enum Keys: String, CodingKey {
        case linkerSettings
        case exclude
    }
}
