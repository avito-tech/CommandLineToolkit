import Foundation
import PathLib

public extension ProcessControllerProvider {
    @available(*, deprecated, message: "Use async version")
    func subprocess(
        arguments: [String],
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming? = nil,
        automaticManagement: AutomaticManagement = .noManagement,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let processController = try createSubprocessController(
            arguments: arguments,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement,
            file: file,
            line: line
        )
        try processController.startAndWaitForSuccessfulTermination()
    }
    
    func subprocessAsync(
        arguments: [String],
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming? = nil,
        automaticManagement: AutomaticManagement = .noManagement,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        let processController = try createSubprocessController(
            arguments: arguments,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement,
            file: file,
            line: line
        )
        try await processController.startAndWaitForSuccessfulTerminationAsync()
    }

    private func createSubprocessController(
        arguments: [String],
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming? = nil,
        automaticManagement: AutomaticManagement = .noManagement,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> ProcessController {
        let subprocess = Subprocess(
            arguments: arguments,
            environment: environment,
            automaticManagement: automaticManagement,
            workingDirectory: currentWorkingDirectory
        )
        
        let outputStreaming = outputStreaming ?? .restream(
            name: arguments.joined(separator: " "),
            file: file,
            line: line
        )
        
        return try withUnsafeCurrentTask { task in
            let processController = try createProcessController(subprocess: subprocess)
            processController.onStdout { _, data, _ in outputStreaming.stdout(data) }
            processController.onStderr { _, data, _ in outputStreaming.stderr(data) }
            processController.onTermination { controller, _ in
                switch controller.processStatus() {
                case .notStarted, .stillRunning:
                    assertionFailure("process controller is still running")
                    outputStreaming.finish(1, task?.isCancelled ?? false)
                case .terminated(exitCode: let code):
                    outputStreaming.finish(code, task?.isCancelled ?? false)
                }
            }
            return processController
        }
    }
}
