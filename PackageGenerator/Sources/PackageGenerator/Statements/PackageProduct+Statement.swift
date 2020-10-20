import Foundation

public extension PackageProduct {
    var statement: String {
        let joinedTargets = targets.map { "\"\($0)\"" }.joined(separator: ", ")
        return "." + productType.rawValue + "(name: \"\(name)\", targets: [\(joinedTargets)])"
    }
}
