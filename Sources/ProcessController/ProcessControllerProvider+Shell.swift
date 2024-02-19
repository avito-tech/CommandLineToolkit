import AtomicModels
import Foundation
import PathLib

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
    
    public init(
        stdout: @escaping (Data) -> (),
        stderr: @escaping (Data) -> ()
    ) {
        self.stdout = stdout
        self.stderr = stderr
    }
    
    public typealias ArrayLiteralElement = OutputStreaming
    public init(arrayLiteral elements: OutputStreaming...) {
        self = OutputStreaming.multiple(elements)
    }
    
    public static let restream = OutputStreaming { data in
        FileHandle.standardOutput.write(data)
    } stderr: { data in
        FileHandle.standardError.write(data)
    }
    
    public static let silent = OutputStreaming { _ in } stderr: { _ in }
    
    public static func multiple(_ streams: [OutputStreaming]) -> OutputStreaming {
        OutputStreaming { data in
            streams.forEach { $0.stdout(data) }
        } stderr: { data in
            streams.forEach { $0.stderr(data) }
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
