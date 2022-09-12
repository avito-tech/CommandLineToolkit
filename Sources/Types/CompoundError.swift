import Foundation

public final class CompoundError: LocalizedError {
    public let errors: [Error]
    public let descriptionPreparer: ([Error]) -> String
    
    public init(
        errors: [Error],
        descriptionPreparer: @escaping ([Error]) -> String = { errors in
            errors.map { "\($0)" }.joined(separator: "\n")
        }
    ) {
        self.errors = errors
        self.descriptionPreparer = descriptionPreparer
    }
    
    public var errorDescription: String? {
        descriptionPreparer(errors)
    }
}
