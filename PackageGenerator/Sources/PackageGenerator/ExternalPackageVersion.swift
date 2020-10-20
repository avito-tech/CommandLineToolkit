import Foundation

/// Defines external package version
public enum ExternalPackageVersion: Codable, Equatable {
    case upToNextMajor(String)
    case exact(String)
    case from(String)
    
    private enum CodingKeys: CodingKey {
        case upToNextMajor
        case exact
        case from
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self = .upToNextMajor(try container.decode(String.self, forKey: .upToNextMajor))
        } catch {
            do {
                self = .exact(try container.decode(String.self, forKey: .exact))
            } catch {
                self = .from(try container.decode(String.self, forKey: .from))
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .exact(value):
            try container.encode(value, forKey: .exact)
        case let .upToNextMajor(value):
            try container.encode(value, forKey: .upToNextMajor)
        case let .from(value):
            try container.encode(value, forKey: .from)
        }
    }
}
