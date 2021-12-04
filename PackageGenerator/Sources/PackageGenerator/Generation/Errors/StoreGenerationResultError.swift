import Foundation

public struct StoreGenerationResultError: Error, CustomStringConvertible {
    let errors: [Error]
    
    public var description: String {
        "Failed to store generated content. Errors: \n" + errors.map { "\($0)" }.joined(separator: "\n")
    }
}
