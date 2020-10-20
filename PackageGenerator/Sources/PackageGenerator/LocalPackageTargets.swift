import Foundation

/// Defines targets of an external locally accessble local package
public enum LocalPackageTargets: Codable, Equatable {
    
    /// External locally accessble packages defines a concrete list of targets
    case targetNames([String])
    
    /// External locally accessble package generates its target list
    case generated
    
    public static let generatedStringRep = "generated"
    
    private enum CodingKeys: CodingKey {
        case targetNames
        case generated
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let stringRep = try container.decode(String.self)
            guard stringRep == LocalPackageTargets.generatedStringRep else {
                fatalError("Must be '\(LocalPackageTargets.generatedStringRep)'")
            }
            self = .generated
        } catch {
            self = .targetNames(try container.decode([String].self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .generated:
            try container.encode(LocalPackageTargets.generatedStringRep)
        case let .targetNames(value):
            try container.encode(value)
        }
    }
}
