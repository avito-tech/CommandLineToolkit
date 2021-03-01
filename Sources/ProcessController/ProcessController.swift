import Foundation

public protocol ProcessController: class {
    var subprocess: Subprocess { get }
    var processName: String { get }
    var processId: Int32 { get }
    
    func start() throws
    func waitForProcessToDie()
    func processStatus() -> ProcessStatus
    func send(signal: Int32)
    
    func terminateAndForceKillIfNeeded()
    func interruptAndForceKillIfNeeded()
    
    func onSignal(listener: @escaping SignalListener)
    func onStart(listener: @escaping StartListener)
    func onStderr(listener: @escaping StderrListener)
    func onStdout(listener: @escaping StdoutListener)
    func onTermination(listener: @escaping TerminationListener)
}

public enum ProcessTerminationError: Error, CustomStringConvertible {
    case unexpectedProcessStatus(name: String, pid: Int32, processStatus: ProcessStatus)
    
    public var description: String {
        switch self {
        case let .unexpectedProcessStatus(name, pid, status):
            return "Process \(name)[\(pid)] has finished with unexpected status: \(status)"
        }
    }
}

public extension ProcessController {
    func startAndListenUntilProcessDies() throws {
        try start()
        waitForProcessToDie()
    }
    
    var isProcessRunning: Bool {
        return processStatus() == .stillRunning
    }
    
    var subprocessInfo: SubprocessInfo {
        return SubprocessInfo(subprocessId: processId, subprocessName: processName)
    }
    
    func startAndWaitForSuccessfulTermination() throws {
        try startAndListenUntilProcessDies()
        let status = processStatus()
        guard status == .terminated(exitCode: 0) else {
            throw ProcessTerminationError.unexpectedProcessStatus(name: processName, pid: processId, processStatus: status)
        }
    }
    
    func forceKillProcess() {
        send(signal: SIGKILL)
    }
}
