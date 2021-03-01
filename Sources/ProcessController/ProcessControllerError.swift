import Foundation
import PathLib

public enum ProcessControllerError: CustomStringConvertible, Error {
    case fileIsNotExecutable(path: AbsolutePath)
    case runtimeError(NSException)
    
    public var description: String {
        switch self {
        case .fileIsNotExecutable(let path):
            return "File is not executable: \(path)"
        case .runtimeError(let objcException):
            return "Runtime error: \(objcException)"
        }
    }
}
