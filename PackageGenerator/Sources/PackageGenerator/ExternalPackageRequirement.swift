import Foundation

/// Defines where external package is located.
public enum ExternalPackageLocation: Codable, Equatable {
    case url(url: String, version: ExternalPackageVersion, targetNames: PackageExposedTargets)
    case local(path: String, targetNames: PackageExposedTargets)
    
    private enum CodingKeys: CodingKey {
        case url
        case version
        case path
        case targetNames
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self = .local(
                path: try container.decode(String.self, forKey: .path),
                targetNames: try container.decode(PackageExposedTargets.self, forKey: .targetNames)
            )
        } catch {
            self = .url(
                url: try container.decode(String.self, forKey: .url),
                version: try container.decode(ExternalPackageVersion.self, forKey: .version),
                targetNames: try container.decode(PackageExposedTargets.self, forKey: .targetNames)
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .local(path, targetNames):
            try container.encode(path, forKey: .path)
            try container.encode(targetNames, forKey: .targetNames)
        case let .url(url, version, targetNames):
            try container.encode(url, forKey: .url)
            try container.encode(version, forKey: .version)
            try container.encode(targetNames, forKey: .targetNames)
        }
    }
}
