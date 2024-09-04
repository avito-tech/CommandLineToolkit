import Foundation

public protocol ProcessController: AnyObject {
    var subprocess: Subprocess { get }
    var processName: String { get }
    var processId: Int32 { get }
    
    func start() throws
    func waitForProcessToDie()
    func waitForProcessToDieAsync() async
    func processStatus() -> ProcessStatus
    func send(signal: Int32)
    
    func signalAndForceKillIfNeeded(
        terminationSignal: Int32,
        terminationSignalTimeout: TimeInterval,
        onKill: @escaping () -> ()
    )
    
    func onSignal(listener: @escaping SignalListener)
    func onStart(listener: @escaping StartListener)
    func onStderr(listener: @escaping StderrListener)
    func onStdout(listener: @escaping StdoutListener)
    func onTermination(listener: @escaping TerminationListener)
}

public enum ProcessTerminationError: Error, CustomStringConvertible {
    case unexpectedProcessStatus(
        name: String,
        arguments: [SubprocessArgument],
        pid: Int32,
        processStatus: ProcessStatus
    )
    
    public var description: String {
        switch self {
        case let .unexpectedProcessStatus(name, arguments, pid, status):
            return "Process \(name)[\(pid)] has finished with unexpected status: \(status). Process arguments: \(arguments.map { "\($0)" }.debugDescription)"
        }
    }
}

public extension ProcessController {
    func startAndListenUntilProcessDies() throws {
        try start()
        waitForProcessToDie()
    }
    
    func startAndListenUntilProcessDies() async throws {
        try Task.checkCancellation()
        try start()
        try await withTaskCancellationHandler {
            await waitForProcessToDieAsync()
        } onCancel: {
            send(signal: SIGINT)
        }
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
            throw ProcessTerminationError.unexpectedProcessStatus(
                name: processName,
                arguments: subprocess.arguments,
                pid: processId,
                processStatus: status
            )
        }
    }
    
    func startAndWaitForSuccessfulTerminationAsync() async throws {
        try await startAndListenUntilProcessDies()
        let status = processStatus()
        guard status == .terminated(exitCode: 0) else {
            throw ProcessTerminationError.unexpectedProcessStatus(
                name: processName,
                arguments: subprocess.arguments,
                pid: processId,
                processStatus: status
            )
        }
    }
    
    func forceKillProcess() {
        send(signal: SIGKILL)
    }
    
    func terminateAndForceKillIfNeeded(
        onKill: @escaping () -> () = {}
    ) {
        signalAndForceKillIfNeeded(
            terminationSignal: SIGTERM,
            terminationSignalTimeout: 15,
            onKill: onKill
        )
    }
    
    func interruptAndForceKillIfNeeded(
        onKill: @escaping () -> () = {}
    ) {
        signalAndForceKillIfNeeded(
            terminationSignal: SIGINT,
            terminationSignalTimeout: 15,
            onKill: onKill
        )
    }
}
