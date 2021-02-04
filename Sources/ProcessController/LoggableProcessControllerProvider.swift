import DateProvider
import Foundation
import FileSystem
import PathLib

public final class LoggableProcessControllerProvider: ProcessControllerProvider {
    public typealias ProcessName = String
    
    private let pathProvider: (ProcessName) throws -> (stdout: AbsolutePath, stderr: AbsolutePath)
    private let provider: ProcessControllerProvider
    
    public init(
        pathProvider: @escaping (ProcessName) throws -> (stdout: AbsolutePath, stderr: AbsolutePath),
        provider: ProcessControllerProvider
    ) {
        self.pathProvider = pathProvider
        self.provider = provider
    }
    
    public func createProcessController(subprocess: Subprocess) throws -> ProcessController {
        let processController = try provider.createProcessController(subprocess: subprocess)
        let outputPaths = try pathProvider(processController.processName)
        
        let stdoutHandle = try FileHandle(forWritingTo: outputPaths.stdout.fileUrl)
        let stderrHandle = try FileHandle(forWritingTo: outputPaths.stderr.fileUrl)
        
        processController.onStdout { _, data, _ in stdoutHandle.write(data) }
        processController.onStderr { _, data, _ in stderrHandle.write(data) }
        
        return processController
    }
}
