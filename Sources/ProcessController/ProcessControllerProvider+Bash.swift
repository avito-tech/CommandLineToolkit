import AtomicModels
import Foundation
import PathLib

// swiftlint:disable multiple_closures_with_trailing_closure

public extension ProcessControllerProvider {
    func bash(
        _ command: String,
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming = .restream,
        automaticManagement: AutomaticManagement = .noManagement
    ) throws {
        let subprocess = Subprocess(
            arguments: ["/bin/bash", "-l", "-c", command],
            environment: environment,
            automaticManagement: automaticManagement,
            workingDirectory: currentWorkingDirectory
        )
        let processController = try createProcessController(subprocess: subprocess)
        processController.onStdout { _, data, _ in outputStreaming.stdout(data) }
        processController.onStderr { _, data, _ in outputStreaming.stderr(data) }
        try processController.startAndWaitForSuccessfulTermination()
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
    public var stdoutSting: String { String(data: stdoutData, encoding: .utf8) ?? "" }
    public var stderrData: Data { stderrStorage.currentValue() }
    public var stderrSting: String { String(data: stderrData, encoding: .utf8) ?? "" }
    
    public var outputStreaming: OutputStreaming {
        return OutputStreaming { data in
            self.stdoutStorage.withExclusiveAccess { $0.append(data) }
        } stderr: { data in
            self.stderrStorage.withExclusiveAccess { $0.append(data) }
        }
    }
}
