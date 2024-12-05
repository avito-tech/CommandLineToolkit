import PathLib

public protocol ImageValidator {
    func validateFormat(path: AbsolutePath) -> FormatValidationResult
    func validatePathToRemove(path: AbsolutePath) -> RemovingValidationResult
}

public enum FormatValidationResult: Equatable {
    case success
    case error(Error)
    
    public enum Error: Equatable {
        case isNotFile
        case wrongFormat(String)
    }
    
    public var isWrongFormat: Bool {
        if case .error(.wrongFormat) = self {
            return true
        }
        return false
    }
}

public enum RemovingValidationResult: Equatable {
    case success
    case error(Error)
    
    public enum Error: Equatable {
        case notAvailable
        case rootCategory
        case wrongFormat(String)
    }
    
    public var isWrongFormat: Bool {
        if case .error(.wrongFormat) = self {
            return true
        }
        return false
    }
}
