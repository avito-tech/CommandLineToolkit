import ArgumentParser
import Logging
import Console
import DI
import TeamcityMessaging

public enum LogFormat: String, Codable, ExpressibleByArgument {
    case interactive
    case teamcity
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

public struct ParsableCommandLogConfiguration {
    public init(consoleBacking: LogHandler?, additionalSystem: [LogHandler]) {
        self.consoleBacking = consoleBacking
        self.additionalSystem = additionalSystem
    }
    
    let consoleBacking: LogHandler?
    let additionalSystem: [LogHandler]
    
    public static let `default` = ParsableCommandLogConfiguration(consoleBacking: nil, additionalSystem: [])
}

extension ParsableCommand {
    
    public var logOptions: LogOptions {
        (self as? LogOptionsCommand)?.logOptions ?? .default
    }
    
    public var logLevel: Logger.Level {
        logOptions.verbose ? .trace : logOptions.logLevel
    }
    
    public func bootstrapLogger(with config: ParsableCommandLogConfiguration = .default) {
        let systemLogHandlerFactory: (String) -> [any LogHandler]
        switch logOptions.logFormat {
        case .interactive:
            ConsoleSystem.bootstrap {
                ANSIConsoleHandler(verbositySettings: .init(logLevel: logLevel, verbose: logOptions.verbose), backing: config.consoleBacking)
            }
            systemLogHandlerFactory = { label in
                [ConsoleLogHandler(label: label)] + config.additionalSystem
            }
        case .teamcity:
            do {
                let messageGenerator = try DiContext.current.resolve() as TeamcityMessageGenerator
                let messageRenderer = try DiContext.current.resolve() as TeamcityMessageRenderer

                ConsoleSystem.bootstrap {
                    TeamcityConsoleHandler(
                        verbositySettings: .init(logLevel: logLevel, verbose: logOptions.verbose),
                        messageGenerator: messageGenerator,
                        messageRenderer: messageRenderer
                    )
                }
                systemLogHandlerFactory = { label in
                    [ConsoleLogHandler(label: label)]
                }
            } catch {
                fatalError("Failed to resolve dependencies with error: \(error)")
            }
        }

        LoggingSystem.bootstrap { label in
            MultiplexLogHandler(systemLogHandlerFactory(label))
        }

        validateLogOptions()
    }

    func validateLogOptions() {
        // We check only commands with logic
        guard self is CommandLogicProvider || self is AsyncCommandLogicProvider else {
            return
        }

        // They should be GlobalArgumentsCommands, otherwise it will be impossible to set log level, and only default will be used
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
