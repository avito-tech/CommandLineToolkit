import Foundation

/// `#if os(<os type>)`
public enum OsRequirement: String, Codable, Hashable {
    case macOS
    case Linux
}

/// Conditional compilation requirement - `#if`
public enum ConditionalCompilationTargetRequirement: Codable, Hashable {
    case os(OsRequirement)
    
    private enum Keys: String, CodingKey {
        case os
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self = try FirstNonThrowingResultOf.perform {
            ConditionalCompilationTargetRequirement.os(
                try container.decode(OsRequirement.self, forKey: .os)
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        switch self {
        case .os(let osRequirement):
            try container.encode(osRequirement, forKey: .os)
        }
    }
}
