import Foundation
import PathLib

public extension ProcessControllerProvider {
    func subprocess(
        arguments: [String],
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming = .restream,
        automaticManagement: AutomaticManagement = .noManagement
    ) throws {
        let processController = try createSubprocessController(
            arguments: arguments,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement
        )
        try processController.startAndWaitForSuccessfulTermination()
    }
    
    func subprocessAsync(
        arguments: [String],
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming = .restream,
        automaticManagement: AutomaticManagement = .noManagement
    ) async throws {
        let processController = try createSubprocessController(
            arguments: arguments,
            environment: environment,
            currentWorkingDirectory: currentWorkingDirectory,
            outputStreaming: outputStreaming,
            automaticManagement: automaticManagement
        )
        try await processController.startAndWaitForSuccessfulTerminationAsync()
    }

    private func createSubprocessController(
        arguments: [String],
        environment: Environment = .current,
        currentWorkingDirectory: AbsolutePath = FileManager().currentAbsolutePath,
        outputStreaming: OutputStreaming = .restream,
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
