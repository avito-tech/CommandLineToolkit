import Foundation
import ProcessController
import SynchronousWaiter

public final class FakeProcessController: ProcessController {
    public var subprocess: Subprocess

    public init(subprocess: Subprocess, processStatus: ProcessStatus = .notStarted) {
        self.subprocess = subprocess
        self.overridedProcessStatus = processStatus
    }
    
    public var processName: String {
        do {
            return try subprocess.arguments[0].stringValue()
        } catch {
            return "Error getting processName: \(error)"
        }
    }
    
    public var processId: Int32 {
        return 0
    }
    
    public func start() {
        for listener in startListeners {
            listener(self, {})
        }
    }
    
    public func waitForProcessToDie() {
        try? SynchronousWaiter().waitWhile { isProcessRunning }
    }

    public func waitForProcessToDieAsync() async {
        await withCheckedContinuation { continuation in
            try? SynchronousWaiter().waitWhile { isProcessRunning }
            continuation.resume()
        }
    }

    public var overridedProcessStatus: ProcessStatus = .notStarted
    
    public func processStatus() -> ProcessStatus {
        return overridedProcessStatus
    }
    
    public var signalsSent = [Int32]()
    
    public func send(signal: Int32) {
        signalsSent.append(signal)
        broadcastSignal(signal)
    }
    
    public func signalAndForceKillIfNeeded(
        terminationSignal: Int32,
        terminationSignalTimeout: TimeInterval,
        onKill: @escaping () -> ()
    ) {
        send(signal: terminationSignal)
        invokeTerminationProcedures(exitCode: terminationSignal)
        onKill()
    }
    
    public func invokeTerminationProcedures(
        exitCode: Int32 = 0
    ) {
        overridedProcessStatus = .terminated(exitCode: exitCode)
        broadcastTermination()
    }
    
    public var startListeners = [StartListener]()
    
    public func onStart(listener: @escaping StartListener) {
        startListeners.append(listener)
    }
    
    // Stdout
    
    public var stdoutListeners = [StdoutListener]()
    
    public func onStdout(listener: @escaping StdoutListener) {
        stdoutListeners.append(listener)
    }
    
    public func broadcastStdout(data: Data) {
        stdoutListeners.forEach { $0(self, data, { }) }
    }
    
    // Stderr
    
    public var stderrListeners = [StdoutListener]()
    
    public func onStderr(listener: @escaping StderrListener) {
        stderrListeners.append(listener)
    }
    
    public func broadcastStderr(data: Data) {
        stderrListeners.forEach { $0(self, data, { }) }
    }
    
    // Signalling
    
    public var signalListeners = [SignalListener]()
    
    public func onSignal(listener: @escaping SignalListener) {
        signalListeners.append(listener)
    }
    
    public func broadcastSignal(_ signal: Int32) {
        signalListeners.forEach { $0(self, signal, { }) }
    }
    
    // Termination
    
    public var terminationListeners = [TerminationListener]()
    
    public func onTermination(listener: @escaping TerminationListener) {
        terminationListeners.append(listener)
    }
    
    public func broadcastTermination() {
        terminationListeners.forEach { $0(self, { }) }
    }
}
