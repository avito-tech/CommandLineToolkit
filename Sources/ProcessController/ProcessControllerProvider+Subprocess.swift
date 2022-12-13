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
        let subprocess = Subprocess(
            arguments: arguments,
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
