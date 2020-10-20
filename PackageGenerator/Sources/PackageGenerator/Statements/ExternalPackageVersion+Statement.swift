import Foundation

public extension ExternalPackageVersion {
    var statement: String {
        switch self {
        case let .exact(value):
            return ".exact(\"\(value)\")"
        case let .upToNextMajor(value):
            return ".upToNextMajor(from: \"\(value)\")"
        case let .from(value):
            return "from: \"\(value)\""
        }
    }
}
