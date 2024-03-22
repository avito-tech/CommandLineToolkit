import Foundation

public extension ExternalPackageVersion {
    var statement: String {
        switch self {
        case let .exact(value):
            return #"exact: "\#(value)""#
        case let .from(value):
            return #"from: "\#(value)""#
        case let .branch(value):
            return #"branch: "\#(value)""#
        case let .revision(value):
            return #"revision: "\#(value)""#
        }
    }
}
