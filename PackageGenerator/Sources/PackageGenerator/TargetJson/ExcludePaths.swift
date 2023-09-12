import Foundation

public enum ExcludePaths: Hashable {
    case single(String)
    case multiple([String])
    
    public static let empty: ExcludePaths = .multiple([])
    
    public var paths: [String] {
        switch self {
        case let .single(path):
            return [ path ]
        case let .multiple(paths):
            return paths
        }
    }
    
    public var isDefined: Bool {
        !paths.isEmpty
    }
    
    public mutating func append(_ path: String...) {
        switch self {
        case let .single(exising):
            self = .multiple([exising] + path)
        case let .multiple(exising):
            self = .multiple(exising + path)
        }
    }
}

extension ExcludePaths: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self = try FirstNonThrowingResultOf.perform({
            .single(try container.decode(String.self))
        }, {
            .multiple(try container.decode([String].self))
        })
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(paths)
    }
}
