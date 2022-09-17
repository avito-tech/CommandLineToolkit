import Foundation

/// Defines what targets package defines.
public indirect enum PackageTargets: Codable, Hashable {
    
    /// A package declares a specific list of targets
    case single(PackageTarget)
    
    /// A list of targets should be discovered automatically.
    case discoverAutomatically
    
    /// A list of targets
    case multiple([PackageTargets])
    
    public static let discoverAutomaticallyStringRep = "discoverAutomatically"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self = try FirstNonThrowingResultOf.perform({
            let stringRep = try container.decode(String.self)
            guard stringRep == PackageTargets.discoverAutomaticallyStringRep else {
                fatalError("The value must be '\(PackageTargets.discoverAutomaticallyStringRep)', but found '\(stringRep)'")
            }
            return .discoverAutomatically
        }, {
            .single(try container.decode(PackageTarget.self))
        }, {
            .multiple(try container.decode([PackageTargets].self))
        })
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .discoverAutomatically:
            try container.encode(PackageTargets.discoverAutomaticallyStringRep)
        case let .single(value):
            try container.encode(value)
        case let .multiple(packageTargets):
            try container.encode(packageTargets)
        }
    }
}
