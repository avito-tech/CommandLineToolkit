import Foundation

/// Defines what targets package defines.
public enum PackageTargets: Codable, Hashable {
    
    /// A package declares a specific list of targets
    case explicit([PackageTarget])
    
    /// A list of targets should be discovered automatically.
    case discoverAutomatically
    
    public static let discoverAutomaticallyStringRep = "discoverAutomatically"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let stringRep = try container.decode(String.self)
            guard stringRep == PackageTargets.discoverAutomaticallyStringRep else {
                fatalError("The value must be '\(PackageTargets.discoverAutomaticallyStringRep)', but found '\(stringRep)'")
            }
            self = .discoverAutomatically
        } catch {
            self = .explicit(try container.decode([PackageTarget].self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .discoverAutomatically:
            try container.encode(PackageTargets.discoverAutomaticallyStringRep)
        case let .explicit(value):
            try container.encode(value)
        }
    }
}
