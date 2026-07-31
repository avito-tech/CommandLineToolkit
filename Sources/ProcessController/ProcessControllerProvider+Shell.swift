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
    ) async throws {
        try await bashOrZsh(
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
    ) async throws -> String {
        let streams = CapturedOutputStreams()
        
        try await bash(
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
    ) async throws {
        try await bashOrZsh(
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
    ) async throws -> String {
        let streams = CapturedOutputStreams()
        
        try await zsh(
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
    ) async throws {
        var arguments = [interpreterPath.pathString]
        
        if isLoginShell {
            arguments += ["-l"]
        }
        
        arguments.append(contentsOf: ["-c", command])
        
        try await subprocessAsync(
            arguments: arguments,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement
        )
    }
}

public struct OutputStreaming: ExpressibleByArrayLiteral {
    /// Defines how `restream` handles output hidden by the current log level.
    public enum HiddenOutputPolicy: Sendable {
        /// Discards output while its log level is hidden.
        case discard

        /// Buffers selected output and replays it when the process finishes with a nonzero status.
        ///
        /// - Parameters:
        ///   - capture: The subprocess streams to buffer.
        ///   - maxBufferedBytes: The positive maximum number of bytes retained per process. Oldest bytes are discarded first.
        case replayOnFailure(
            capture: OutputCapture,
            maxBufferedBytes: Int
        )
    }

    /// Selects subprocess streams to buffer for a failure replay.
    public enum OutputCapture: Sendable, Equatable {
        /// Buffers only the standard error stream.
        case stderr

        /// Buffers both standard output and standard error in callback delivery order.
        case stdoutAndStderr
    }

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

    /// Streams process output through `Console`.
    ///
    /// Output below the active log level is handled according to `hiddenOutput`.
    ///
    /// - Parameters:
    ///   - level: The level used to render process output.
    ///   - name: The display name of the process output stream.
    ///   - renderTail: The number of trailing lines rendered while an interactive process is running.
    ///   - hiddenOutput: The policy applied when `level` is hidden by current verbosity settings.
    ///   - ignoreNonZeroStatusCode: Whether a nonzero process status should be rendered as success.
    ///   - file: The source file that created the stream.
    ///   - line: The source line that created the stream.
    /// - Returns: Output callbacks suitable for a `ProcessController`.
    public static func restream(
        level: Logger.Level = .debug,
        name: String,
        renderTail: Int = 3,
        hiddenOutput: HiddenOutputPolicy = .discard,
        ignoreNonZeroStatusCode: Bool = false,
        file: StaticString = #file,
        line: UInt = #line
    ) -> OutputStreaming {
        let console = Console()

        switch hiddenOutput {
        case .discard:
            break
        case let .replayOnFailure(capture, maxBufferedBytes):
            precondition(maxBufferedBytes > 0, "maxBufferedBytes must be greater than zero")

            if !console.isLogEnabled(at: level) {
                return Console.withEscapingContext { continuation in
                    failureReplay(
                        capture: capture,
                        maxBufferedBytes: maxBufferedBytes,
                        ignoreNonZeroStatusCode: ignoreNonZeroStatusCode
                    ) { data, wasTruncated, status in
                        continuation.yield {
                            renderFailureReplay(
                                data: data,
                                wasTruncated: wasTruncated,
                                maxBufferedBytes: maxBufferedBytes,
                                status: status,
                                console: console,
                                name: name,
                                renderTail: renderTail,
                                file: file,
                                line: line
                            )
                        }
                    }
                }
            }
        }

        return liveRestream(
            level: level,
            name: name,
            renderTail: renderTail,
            ignoreNonZeroStatusCode: ignoreNonZeroStatusCode,
            console: console,
            file: file,
            line: line
        )
    }

    static func failureReplay(
        capture: OutputCapture,
        maxBufferedBytes: Int,
        ignoreNonZeroStatusCode: Bool,
        replay: @escaping (_ data: Data, _ wasTruncated: Bool, _ status: Int32) -> ()
    ) -> OutputStreaming {
        precondition(maxBufferedBytes > 0, "maxBufferedBytes must be greater than zero")

        let buffer = BoundedOutputBuffer(maxBufferedBytes: maxBufferedBytes)

        return OutputStreaming { data in
            if capture == .stdoutAndStderr {
                buffer.append(data)
            }
        } stderr: { data in
            buffer.append(data)
        } finish: { status, cancelled in
            guard status != 0, !ignoreNonZeroStatusCode, !cancelled else {
                return
            }

            let snapshot = buffer.snapshot()
            replay(snapshot.data, snapshot.wasTruncated, status)
        }
    }

    private static func liveRestream(
        level: Logger.Level,
        name: String,
        renderTail: Int,
        ignoreNonZeroStatusCode: Bool,
        console: Console,
        file: StaticString,
        line: UInt
    ) -> OutputStreaming {
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

    private static func renderFailureReplay(
        data: Data,
        wasTruncated: Bool,
        maxBufferedBytes: Int,
        status: Int32,
        console: Console,
        name: String,
        renderTail: Int,
        file: StaticString,
        line: UInt
    ) {
        guard wasTruncated || !data.isEmpty else {
            return
        }

        let sink = console.logStream(level: .error, name: name, renderTail: renderTail, file: file, line: line)

        if wasTruncated {
            sink.append(line: "Output truncated; showing the last \(maxBufferedBytes) bytes")
        }

        let replayStream = MessageStream { message in
            sink.append(line: message)
        } replaceLine: { message in
            sink.replace(line: message)
        }

        let validUTF8Data = Data(String(decoding: data, as: UTF8.self).utf8)
        replayStream.append(data: validUTF8Data)
        replayStream.flushMessageIfMessageIsNotEmpty()
        sink.finish(result: .failure(.init(statusCode: status)), cancelled: false)
    }
}

private final class BoundedOutputBuffer {
    struct Snapshot {
        var data: Data
        var wasTruncated: Bool
    }

    private let maxBufferedBytes: Int
    private let storage = AtomicValue(Snapshot(data: Data(), wasTruncated: false))

    init(maxBufferedBytes: Int) {
        self.maxBufferedBytes = maxBufferedBytes
    }

    func append(_ newData: Data) {
        storage.withExclusiveAccess { state in
            if newData.count >= maxBufferedBytes {
                let discardedBytes = !state.data.isEmpty || newData.count > maxBufferedBytes
                state.data = Data(newData.suffix(maxBufferedBytes))
                state.wasTruncated = state.wasTruncated || discardedBytes
                return
            }

            state.data.append(newData)

            let overflow = state.data.count - maxBufferedBytes
            if overflow > 0 {
                state.data.removeFirst(overflow)
                state.wasTruncated = true
            }
        }
    }

    func snapshot() -> Snapshot {
        storage.currentValue()
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
