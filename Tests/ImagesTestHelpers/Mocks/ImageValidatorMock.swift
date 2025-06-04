import ImagesInterfaces
import PathLib

public final class ImageValidatorMock: ImageValidator {
    
    public var validateFormatInputPath: AbsolutePath?
    public var validateSizeInputPath: AbsolutePath?
    public var validatePathToRemoveInputPath: AbsolutePath?
    
    public var validateFormatResult: FormatValidationResult = .success
    public var validateSizeResult: SizeValidationResult = .success
    public var validatePathToRemoveResult: RemovingValidationResult = .success
    
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
        return validatePathToRemoveResult
    }
}
