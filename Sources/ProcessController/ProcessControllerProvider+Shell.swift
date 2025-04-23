import AtomicModels
import Foundation
import PathLib
import Logging
import Console

// swiftlint:disable multiple_closures_with_trailing_closure

// Suggestion: avoid using shells if not needed, consider using `func subprocess` for running processes.
extension ProcessControllerProvider {
    public func bash(
        _ command: String,
        isLoginShell: Bool, // suggestion: avoid "true" as much as possible if you want to achieve more predictable behavior
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming = .restream,
        automaticManagement: AutomaticManagement = .noManagement
    ) throws {
        try bashOrZsh(
            command,
            interpreterPath: "/bin/bash",
            isLoginShell: isLoginShell,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement
        )
    }
    
    public func bash(
        isLoginShell: Bool = false, // suggestion: avoid "true" as much as possible if you want to achieve more predictable behavior
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        automaticManagement: AutomaticManagement = .noManagement,
        command: () -> String
    ) throws -> String {
        let streams = CapturedOutputStreams()
        
        try bash(
            command(),
            isLoginShell: isLoginShell,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: streams.outputStreaming,
            automaticManagement: automaticManagement
        )
        
        return streams.stdoutString
    }
    
    public func zsh(
        _ command: String,
        isLoginShell: Bool, // suggestion: avoid "true" as much as possible if you want to achieve more predictable behavior
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming = .restream,
        automaticManagement: AutomaticManagement = .noManagement
    ) throws {
        try bashOrZsh(
            command,
            interpreterPath: "/bin/zsh",
            isLoginShell: isLoginShell,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement
        )
    }
    
    public func zsh(
        isLoginShell: Bool = false, // suggestion: avoid "true" as much as possible if you want to achieve more predictable behavior
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        automaticManagement: AutomaticManagement = .noManagement,
        command: () -> String
    ) throws -> String {
        let streams = CapturedOutputStreams()
        
        try zsh(
            command(),
            isLoginShell: isLoginShell,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: streams.outputStreaming,
            automaticManagement: automaticManagement
        )
        
        return streams.stdoutString
    }
    
    // bash and zsh share "-l" option (note that it may be not true for different interpreters or options)
    private func bashOrZsh(
        _ command: String,
        interpreterPath: AbsolutePath,
        isLoginShell: Bool,
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming = .restream,
        automaticManagement: AutomaticManagement = .noManagement
    ) throws {
        var arguments = [interpreterPath.pathString]
        
        if isLoginShell {
            arguments += ["-l"]
        }
        
        arguments.append(contentsOf: ["-c", command])
        
        try subprocess(
            arguments: arguments,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement
        )
    }
}

public struct OutputStreaming: ExpressibleByArrayLiteral {
    public let stdout: (Data) -> ()
    public let stderr: (Data) -> ()
    public let finish: (_ status: Int32, _ isCancelled: Bool) -> ()
    
    public init(
        stdout: @escaping (Data) -> (),
        stderr: @escaping (Data) -> (),
        finish: @escaping (Int32, Bool) -> () = { _, _ in }
    ) {
        self.stdout = stdout
        self.stderr = stderr
        self.finish = finish
    }
    
    public typealias ArrayLiteralElement = OutputStreaming
    public init(arrayLiteral elements: OutputStreaming...) {
        self = OutputStreaming.multiple(elements)
    }
    
    public static var restream: Self { .restream(name: "process") }
    
    public static let silent = OutputStreaming { _ in } stderr: { _ in }
    
    public static func multiple(_ streams: [OutputStreaming]) -> OutputStreaming {
        OutputStreaming { data in
            streams.forEach { $0.stdout(data) }
        } stderr: { data in
            streams.forEach { $0.stderr(data) }
        } finish: { status, cancelled in
            streams.forEach { $0.finish(status, cancelled) }
        }
    }

    public static var rawOutput: OutputStreaming {
        let stdoutStream = MessageStream { message in
            print(message)
        } replaceLine: { message in
            print(message)
        }
        let stderrStream = MessageStream { message in
            print(message)
        } replaceLine: { message in
            print(message)
        }
        return OutputStreaming { data in
            stdoutStream.append(data: data)
        } stderr: { data in
            stderrStream.append(data: data)
        } finish: { _, _ in
            stdoutStream.flushMessageIfMessageIsNotEmpty()
            stderrStream.flushMessageIfMessageIsNotEmpty()
        }
    }

    public static func restream(
        level: Logger.Level = .debug,
        name: String,
        renderTail: Int = 3,
        ignoreNonZeroStatusCode: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) -> OutputStreaming {
        let console = Console()
        let sink = console.logStream(level: level, name: name, renderTail: renderTail, file: file, line: line)
        
        let stdoutStream = MessageStream { message in
            sink.append(line: message)
        } replaceLine: { message in
            sink.replace(line: message)
        }
        let stderrStream = MessageStream { message in
            sink.append(line: message)
        } replaceLine: { message in
            sink.replace(line: message)
        }
        
        return Console.withEscapingContext { continuation in
            return OutputStreaming { data in
                continuation.yield {
                    stdoutStream.append(data: data)
                }
            } stderr: { data in
                continuation.yield {
                    stderrStream.append(data: data)
                }
            } finish: { status, cancelled in
                continuation.yield {
                    stdoutStream.flushMessageIfMessageIsNotEmpty()
                    stderrStream.flushMessageIfMessageIsNotEmpty()
                    let isSuccess = status == 0 || ignoreNonZeroStatusCode
                    sink.finish(result: isSuccess ? .success(()) : .failure(.init(statusCode: status)), cancelled: cancelled)
                }
            }
        }
    }
}

private struct MessageStream {
    @AtomicValue
    private var stringStream: Substring = ""

    @AtomicValue
    private var lastControlCharacter: Character = "\n"

    private let addLine: (String) -> ()
    private let replaceLine: (String) -> ()

    init(
        addLine: @escaping (String) -> (),
        replaceLine: @escaping (String) -> ()
    ) {
        self.addLine = addLine
        self.replaceLine = replaceLine
    }
    
    func append(data: Data) {
        var dataString = stringStream + string(data: data)[...]

        while let firstControlCharacterIndex = firstControlCharacterIndex(for: dataString) {
            let message = String(dataString[..<firstControlCharacterIndex])
            flushMessage(message)
            lastControlCharacter = dataString[firstControlCharacterIndex]
            dataString = dataString[dataString.index(after: firstControlCharacterIndex)...]
        }

        stringStream = dataString
    }

    private func firstControlCharacterIndex(for substring: Substring) -> String.Index? {
        substring.firstIndex { $0 == "\n" || $0 == "\r" }
    }
    
    func flushMessageIfMessageIsNotEmpty() {
        if !stringStream.isEmpty {
            flushMessageAndClearStringStream()
        }
    }
    
    private func flushMessageAndClearStringStream() {
        flushMessage(String(stringStream))
        stringStream = ""
    }

    private func flushMessage(_ message: String) {
        switch lastControlCharacter {
        case "\n":
            addLine(message)
        case "\r":
            replaceLine(message)
        default:
            addLine(message)
        }
    }
    
    private func string(data: Data) -> String {
        do {
            return try String(utf8Data: data)
        } catch {
            return error.localizedDescription
        }
    }
}

public final class CapturedOutputStreams {
    public init() {}
    
    private let stdoutStorage = AtomicValue(Data())
    private let stderrStorage = AtomicValue(Data())
    
    public var stdoutData: Data { stdoutStorage.currentValue() }
    @available(*, deprecated, renamed: "stdoutString")
    public var stdoutSting: String { stdoutString }
    public var stdoutString: String { String(data: stdoutData, encoding: .utf8) ?? "" }
    public var stdoutLines: [Substring] { stdoutString.split(separator: "\n") }
    
    public var stderrData: Data { stderrStorage.currentValue() }
    @available(*, deprecated, renamed: "stderrString")
    public var stderrSting: String { stderrString }
    public var stderrString: String { String(data: stderrData, encoding: .utf8) ?? "" }
    public var stderrLines: [Substring] { stderrString.split(separator: "\n") }
    
    public var outputStreaming: OutputStreaming {
        return OutputStreaming { data in
            self.stdoutStorage.withExclusiveAccess { $0.append(data) }
        } stderr: { data in
            self.stderrStorage.withExclusiveAccess { $0.append(data) }
        }
    }
}
