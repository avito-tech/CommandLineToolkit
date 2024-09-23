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
        }
        let stderrStream = MessageStream { message in
            sink.append(line: message)
        }
        
        return OutputStreaming { data in
            stdoutStream.append(data: data)
        } stderr: { data in
            stderrStream.append(data: data)
        } finish: { status, cancelled in
            stdoutStream.flushMessageIfMessageIsNotEmpty()
            stderrStream.flushMessageIfMessageIsNotEmpty()
            let isSuccess = status == 0 || ignoreNonZeroStatusCode
            sink.finish(result: isSuccess ? .success(()) : .failure(.init(statusCode: status)), cancelled: cancelled)
        }
    }
}

private struct MessageStream {
    @AtomicValue
    private var stringStream = ""
    private let flushMessage: (String) -> ()
    
    init(
        flushMessage: @escaping (String) -> ()
    ) {
        self.flushMessage = flushMessage
    }
    
    func append(data: Data) {
        let stringComponents = Array(
            string(data: data).split(
                omittingEmptySubsequences: false,
                whereSeparator: { $0 == "\n" }
            ).map { String($0) } // Unfortunately, `Logger` doesn't work with substrings, and it is easier anyway to just use strings
        )
        
        if stringComponents.isEmpty {
            // Impossible case for result of split, not worth properly handling like throwing and error
            flushMessage("String components count of the result of split is: \(stringComponents.count). This case has to be impossible, or something is horribly wrong.")
        } else if stringComponents.count == 1 {
            // String is not split into components by new line => Data has no new line, can't log it,
            // because we don't want to have extra newlines when there aren't newlines in `data`
            let singleComponent = stringComponents[0]
            stringStream += singleComponent
        } else {
            // stringComponents.count >= 1
            
            // Flush buffer with new component, as it has corresponding newline character
            let firstComponent = stringComponents[0]
            stringStream.append(firstComponent)
            flushMessageAndClearStringStream()
            
            // For every component with new line, flush it and don't use buffer
            if stringComponents.count > 2 {
                for index in 1..<(stringComponents.count - 1) {
                    let intermediateComponent = stringComponents[index]
                    flushMessage(intermediateComponent)
                }
            }
            
            // Last component has no corresponding newline character and needs to be added to buffer
            if stringComponents.count > 1 {
                let lastComponent = stringComponents[stringComponents.count - 1]
                
                stringStream.append(lastComponent)
            }
        }
    }
    
    func flushMessageIfMessageIsNotEmpty() {
        if !stringStream.isEmpty {
            flushMessageAndClearStringStream()
        }
    }
    
    private func flushMessageAndClearStringStream() {
        flushMessage(stringStream)
        stringStream = ""
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
