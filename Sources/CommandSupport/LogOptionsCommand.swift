import ArgumentParser
import Logging
import Console

public enum LogFormat: String, Codable, ExpressibleByArgument {
    case interactive
}

public struct LogOptions: ParsableArguments {
    @Flag(name: .shortAndLong)
    public var verbose: Bool = false

    @Option
    public var logLevel: Logger.Level = .info

    @Option
    public var logFormat: LogFormat = .interactive

    public init() {}

    public static var `default`: Self {
        var args = LogOptions()
        args.verbose = false
        args.logLevel = .info
        args.logFormat = .interactive
        return args
    }
}

@dynamicMemberLookup
public protocol LogOptionsCommand {
    var logOptions: LogOptions { get }
}

extension LogOptionsCommand {
    public subscript <Value>(dynamicMember keyPath: KeyPath<LogOptions, Value>) -> Value {
        logOptions[keyPath: keyPath]
    }
}

extension ParsableCommand {
    public func bootstrapLogger() {
        let options = (self as? LogOptionsCommand)?.logOptions ?? .default

        let logLevel = options.verbose ? .trace : options.logLevel

        switch options.logFormat {
        case .interactive:
            ConsoleSystem.bootstrap {
                ANSIConsoleHandler(logLevel: logLevel, verbose: options.verbose)
            }
        }

        LoggingSystem.bootstrap { label in
            ConsoleLogHandler(label: label)
        }

        validateLogOptions()
    }

    func validateLogOptions() {
        // We check only commands with logic
        guard self is CommandLogicProvider || self is AsyncCommandLogicProvider else {
            return
        }

        // They should be GlobalArgumentsCommands, otherwise it will be impossible to set log level, and only defailt will be used
        if self is LogOptionsCommand {
            return
        }

        Logger(label: "CLT").warning(
            """
            Command \(type(of: self)) is not \(LogOptionsCommand.self), add conformance please.
            """
        )
    }
}

extension Logger.Level: ExpressibleByArgument {}
