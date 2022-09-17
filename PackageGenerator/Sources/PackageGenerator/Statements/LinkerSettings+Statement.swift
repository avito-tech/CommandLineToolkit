import Foundation

public extension LinkerSettings {
    var statements: [String] {
        var result = [String]()
        if !unsafeFlags.isEmpty {
            result.append(".unsafeFlags([" + unsafeFlags.map { "\"\($0)\"" }.joined(separator: ", ") + "])")
        }
        return result
    }
}
