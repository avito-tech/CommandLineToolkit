import ImagesInterfaces
import PathLib

public final class ImageValidatorMock: ImageValidator {
    
    public var validateFormatInputPath: AbsolutePath?
    public var validateSizeInputPath: AbsolutePath?
    public var validatePathToRemoveInputPath: AbsolutePath?
    public private(set) var validatePathToRemoveInputPaths: [AbsolutePath] = []
    private var validatePathToRemoveCallIndex: Int = 0
    
    public var validateFormatResult: FormatValidationResult = .success
    public var validateSizeResult: SizeValidationResult = .success
    public var validatePathToRemoveResult: RemovingValidationResult = .success
    public var validatePathToRemoveResults: [RemovingValidationResult] = []
    
    public init() {}
    
    public func validateFormat(path: AbsolutePath) -> FormatValidationResult {
        validateFormatInputPath = path
        return validateFormatResult
    }
    
    public func validateSize(path: AbsolutePath) -> SizeValidationResult {
        validateSizeInputPath = path
        return validateSizeResult
    }
    
    public func validatePathToRemove(path: AbsolutePath) -> RemovingValidationResult {
        validatePathToRemoveInputPath = path
        validatePathToRemoveInputPaths.append(path)
        defer { validatePathToRemoveCallIndex += 1 }
        if validatePathToRemoveCallIndex < validatePathToRemoveResults.count {
            return validatePathToRemoveResults[validatePathToRemoveCallIndex]
        }
        return validatePathToRemoveResult
    }
}
