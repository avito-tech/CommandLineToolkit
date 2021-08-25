import Foundation

final class StringPathParsing {
    static func slashSeparatedComponents<S: StringProtocol>(path: S) -> [String] {
        return path.components(separatedBy: "/").filter { !$0.isEmpty }
    }
    
    static func slashSeparatedComponents<S: StringProtocol>(paths: [S]) -> [String] {
        return paths.flatMap {
            slashSeparatedComponents(path: $0)
        }
    }
}
