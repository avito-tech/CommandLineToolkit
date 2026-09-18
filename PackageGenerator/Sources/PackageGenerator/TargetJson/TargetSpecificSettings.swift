import Foundation

public struct TargetSpecificSettings: Codable, Hashable {
    public static let targetSpecificSettingsFile = "target.json"
    
    public let linkerSettings: LinkerSettings
    public let excludePaths: ExcludePaths
    public let swiftSettings: SwiftSettings
    public let ignoreCommonSwiftSettings: Bool?
    
    /// Target is a macro implementation, emitted as `.macro(...)` (requires `import CompilerPluginSupport`)
    public let isMacro: Bool?
    
    /// Dependencies that cannot be inferred from imports, e.g. a macro target:
    /// depending on it makes its plugin available for macro expansion, but importing it is forbidden.
    public let additionalDependencies: Set<String>
    
    public init(
        linkerSettings: LinkerSettings = .init(unsafeFlags: []),
        excludePaths: ExcludePaths = .empty,
        swiftSettings: SwiftSettings = .empty,
        ignoreCommonSwiftSettings: Bool? = nil,
        isMacro: Bool? = nil,
        additionalDependencies: Set<String> = []
    ) {
        self.linkerSettings = linkerSettings
        self.excludePaths = excludePaths
        self.swiftSettings = swiftSettings
        self.ignoreCommonSwiftSettings = ignoreCommonSwiftSettings
        self.isMacro = isMacro
        self.additionalDependencies = additionalDependencies
    }
    
    public var isDefined: Bool {
        linkerSettings.isDefined || excludePaths.isDefined || swiftSettings.isDefined
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.linkerSettings = try container.decodeIfPresent(LinkerSettings.self, forKey: .linkerSettings) ?? LinkerSettings(unsafeFlags: [])
        self.swiftSettings = try container.decodeIfPresent(SwiftSettings.self, forKey: .swiftSettings) ?? .empty
        self.ignoreCommonSwiftSettings = try container.decodeIfPresent(Bool.self, forKey: .ignoreCommonSwiftSettings)
        self.isMacro = try container.decodeIfPresent(Bool.self, forKey: .isMacro)
        self.additionalDependencies = try container.decodeIfPresent(Set<String>.self, forKey: .additionalDependencies) ?? []
        var exclude = try container.decodeIfPresent(ExcludePaths.self, forKey: .exclude) ?? .empty
        if self.linkerSettings.isDefined || exclude.isDefined || self.swiftSettings.isDefined || self.isMacro == true || !self.additionalDependencies.isEmpty {
            exclude.append(Self.targetSpecificSettingsFile)
        }
        self.excludePaths = exclude
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        if linkerSettings.isDefined { try container.encode(linkerSettings, forKey: .linkerSettings) }
        if excludePaths.isDefined { try container.encode(excludePaths, forKey: .exclude) }
        if swiftSettings.isDefined { try container.encode(swiftSettings, forKey: .swiftSettings) }
        if let ignoreCommonSwiftSettings { try container.encode(ignoreCommonSwiftSettings, forKey: .ignoreCommonSwiftSettings) }
        if let isMacro { try container.encode(isMacro, forKey: .isMacro) }
        if !additionalDependencies.isEmpty { try container.encode(additionalDependencies, forKey: .additionalDependencies) }
    }
    
    private enum Keys: String, CodingKey {
        case linkerSettings
        case exclude
        case swiftSettings
        case ignoreCommonSwiftSettings
        case isMacro
        case additionalDependencies
    }
}
