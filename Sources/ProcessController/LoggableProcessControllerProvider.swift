import DateProvider
import Foundation
import FileSystem
import PathLib
import Tmp

public final class LoggableProcessControllerProvider: ProcessControllerProvider {
    public typealias ProcessName = String
    
    private let filesProvider: (ProcessName) throws -> (stdout: TemporaryFile, stderr: TemporaryFile)
    private let provider: ProcessControllerProvider
    
    public init(
        filesProvider: @escaping (ProcessName) throws -> (stdout: TemporaryFile, stderr: TemporaryFile),
        provider: ProcessControllerProvider
    ) {
        self.filesProvider = filesProvider
        self.provider = provider
    }
    
    public func createProcessController(subprocess: Subprocess) throws -> ProcessController {
        let processController = try provider.createProcessController(subprocess: subprocess)
        let (stdoutFile, stderrFile) = try filesProvider(processController.processName)
        
        processController.onStdout { _, data, _ in stdoutFile.fileHandleForWriting.write(data) }
        processController.onStderr { _, data, _ in stderrFile.fileHandleForWriting.write(data) }
        
        return processController
    }
}
