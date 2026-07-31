import Foundation
import PathLib

public extension ProcessControllerProvider {
    func subprocessAsync(
        arguments: [String],
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming? = nil,
        automaticManagement: AutomaticManagement = .noManagement,
        file: StaticString = #file,
        line: UInt = #line
    ) async throws {
        let outputStreaming = outputStreaming ?? .restream(
            name: arguments.joined(separator: " "),
            file: file,
            line: line
        )
        let processController = try createSubprocessController(
            arguments: arguments,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement
        )

        defer {
            switch processController.processStatus() {
            case .notStarted, .stillRunning:
                outputStreaming.finish(1, Task.isCancelled)
            case .terminated(exitCode: let code):
                outputStreaming.finish(code, Task.isCancelled)
            }
        }

        try await processController.startAndWaitForSuccessfulTerminationAsync()
    }

    private func createSubprocessController(
        arguments: [String],
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming,
        automaticManagement: AutomaticManagement = .noManagement
    ) throws -> ProcessController {
        let subprocess = Subprocess(
            arguments: arguments,
            environment: environment,
            automaticManagement: automaticManagement,
            workingDirectory: currentWorkingDirectory
        )

        let processController = try createProcessController(subprocess: subprocess)
        processController.onStdout { _, data, _ in outputStreaming.stdout(data) }
        processController.onStderr { _, data, _ in outputStreaming.stderr(data) }
        return processController
    }
}
