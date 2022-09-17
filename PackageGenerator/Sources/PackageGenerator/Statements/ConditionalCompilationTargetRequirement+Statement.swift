import Foundation

public extension ConditionalCompilationTargetRequirement {
    var statement: String {
        switch self {
        case .os(let osRequirement):
            return "os(\(osRequirement.statement))"
        }
    }
}
