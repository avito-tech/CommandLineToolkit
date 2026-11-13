import Foundation

public enum BinaryTargetLocation: Codable, Hashable {
    case local(path: String)
    case remote(url: String, checksum: String)

    private enum CodingKeys: CodingKey {
        case url
        case checksum
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let path = try? value.decode(String.self) {
            self = .local(path: path)
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = .remote(
            url: try container.decode(String.self, forKey: .url),
            checksum: try container.decode(String.self, forKey: .checksum)
        )
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .local(path):
            var container = encoder.singleValueContainer()
            try container.encode(path)
        case let .remote(url, checksum):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(url, forKey: .url)
            try container.encode(checksum, forKey: .checksum)
        }
    }
}
