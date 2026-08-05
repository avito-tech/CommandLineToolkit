import PathLib

public enum ImageAssetKind: Equatable {
    case vector
    case raster

    public init?(fileExtension: String) {
        switch fileExtension.lowercased() {
        case "pdf", "svg":
            self = .vector
        case "png", "jpg", "jpeg":
            self = .raster
        default:
            return nil
        }
    }
}

public protocol ImageValidator {
    func validateFormat(path: AbsolutePath) -> FormatValidationResult
    func validateSize(path: AbsolutePath) -> SizeValidationResult
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

public enum SizeValidationResult: Equatable {
    case success
    case error(Error)
    
    public enum Error: Equatable {
        case isNotFile
        case tooLarge(String)
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
