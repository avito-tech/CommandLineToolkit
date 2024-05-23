import Foundation
import Signals

// swiftlint:disable sync
public enum Signal: Hashable, CustomStringConvertible, RawRepresentable {
    case hup
    case int
    case quit
    case abrt
    case kill
    case alrm
    case term
    case pipe
    case user(Int32)

    public init(rawValue: Int32) {
        self = switch rawValue {
        case SIGHUP:
            .hup
        case SIGINT:
            .int
        case SIGQUIT:
            .quit
        case SIGABRT:
            .abrt
        case SIGKILL:
            .kill
        case SIGALRM:
            .alrm
        case SIGTERM:
            .term
        case SIGPIPE:
            .pipe
        default:
            .user(rawValue)
        }
    }

    public var description: String {
        switch self {
        case .hup:
            return "SIGHUP"
        case .int:
            return "SIGINT"
        case .quit:
            return "SIGQUIT"
        case .abrt:
            return "SIGABRT"
        case .kill:
            return "SIGKILL"
        case .alrm:
            return "SIGALRM"
        case .term:
            return "SIGTERM"
        case .pipe:
            return "SIGPIPE"
        case .user(let value):
            return "SIGUSR(\(value))"
        }
    }
    
    public var intValue: Int32 {
        switch self {
        case .hup:
            return SIGHUP
        case .int:
            return SIGINT
        case .quit:
            return SIGQUIT
        case .abrt:
            return SIGABRT
        case .kill:
            return SIGKILL
        case .alrm:
            return SIGALRM
        case .term:
            return SIGTERM
        case .pipe:
            return SIGPIPE
        case .user(let value):
            return Int32(value)
        }
    }

    public var rawValue: Int32 {
        intValue
    }

    var blueSignal: Signals.Signal {
        switch self {
        case .hup:
            return .hup
        case .int:
            return .int
        case .quit:
            return .quit
        case .abrt:
            return .abrt
        case .kill:
            return .kill
        case .alrm:
            return .alrm
        case .term:
            return .term
        case .pipe:
            return .pipe
        case .user(let value):
            return .user(Int(value))
        }
    }
}
