import Foundation

public struct TargetSpecificSettings: Codable, Hashable {
    public let linkerSettings: LinkerSettings
    
    public init(
        linkerSettings: LinkerSettings
    ) {
        self.linkerSettings = linkerSettings
    }
}
