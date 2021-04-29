import Foundation

public enum LaunchdSocketActivationError: CustomStringConvertible, Error {
    public static let noSocket = LaunchdSocketActivationError.errorCode(ENOENT)
    public static let notManagedByLaunchd = LaunchdSocketActivationError.errorCode(ESRCH)
    public static let socketAlreadyActivated = LaunchdSocketActivationError.errorCode(EALREADY)
    
    case errorCode(Int32)
    
    public var description: String {
        switch self {
        case let .errorCode(code):
            switch code {
            case ENOENT:
                return "There was no socket of the specified name owned by the caller"
            case ESRCH:
                return "The caller is not a process managed by launchd"
            case EALREADY:
                return "The socket has already been activated by the caller"
            default:
                return "Unknown error code: \(code)"
            }
        }
    }
}
