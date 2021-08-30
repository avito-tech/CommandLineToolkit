import Foundation

final class StringPathParsing {
    static func slashSeparatedComponents<S: StringProtocol>(path: S) -> [String] {
        return filteringDotComponents(
            components: slashSeparatedComponentsWithoutFiltering(path: path)
        )
    }
    
    static func slashSeparatedComponents<S: StringProtocol>(paths: [S]) -> [String] {
        return filteringDotComponents(
            components: paths.flatMap {
                slashSeparatedComponentsWithoutFiltering(path: $0)
            }
        )
    }
    
    private static func slashSeparatedComponentsWithoutFiltering<S: StringProtocol>(path: S) -> [String] {
        return path.components(separatedBy: "/").filter { !$0.isEmpty }
    }
    
    private static func filteringDotComponents(components: [String]) -> [String] {
        return components.filter {
            $0 != "."
        }
    }
}
