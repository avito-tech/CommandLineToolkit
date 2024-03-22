import Foundation

/// Defines external package version
public enum ExternalPackageVersion: Codable, Hashable {
    case exact(String)
    case from(String)
    case branch(String)
    case revision(String)
    
    private enum CodingKeys: CodingKey {
        case exact
        case from
        case branch
        case revision
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = try FirstNonThrowingResultOf.perform({
            .exact(try container.decode(String.self, forKey: .exact))
        }, {
            .from(try container.decode(String.self, forKey: .from))
        }, {
            .branch(try container.decode(String.self, forKey: .branch))
        }, {
            .revision(try container.decode(String.self, forKey: .revision))
        })
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .exact(value):
            try container.encode(value, forKey: .exact)
        case let .from(value):
            try container.encode(value, forKey: .from)
        case let .branch(value):
            try container.encode(value, forKey: .branch)
        case let .revision(value):
            try container.encode(value, forKey: .revision)
        }
    }
}
