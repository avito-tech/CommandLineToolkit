import DateProvider
import Dispatch
import FileSystem
import Foundation
import PathLib
import Timer
import ObjCExceptionCatcher

// swiftlint:disable async
// swiftlint:disable sync
public final class DefaultProcessController: ProcessController, CustomStringConvertible {
    public let subprocess: Subprocess
    public let processName: String
    public private(set) var processId: Int32 = 0
    
    private let automaticManagementItemControllers: [AutomaticManagementItemController]
    private let fileSystem: FileSystem
    let listenerQueue = DispatchQueue(label: "DefaultProcessController.listenerQueue")
    private let openPipeFileHandleGroup = DispatchGroup()
    private let process: Process
    private let processTerminationHandlerGroup = DispatchGroup()
    private let processTerminationQueue = DispatchQueue(label: "DefaultProcessController.processTerminationQueue")
    private var automaticManagementTrackingTimer: DispatchBasedTimer?
    
    private var didInitiateKillOfProcess = false
    private var didStartProcess = false
    private var signalListeners = [ListenerWrapper<SignalListener>]()
    private var startListeners = [ListenerWrapper<StartListener>]()
    private var stderrListeners = [ListenerWrapper<StderrListener>]()
    private var stdoutListeners = [ListenerWrapper<StdoutListener>]()
    private var terminationListeners = [ListenerWrapper<TerminationListener>]()
    
    private final class ListenerWrapper<T> {
        let uuid: UUID
        let listener: T

        init(uuid: UUID, listener: T) {
            self.uuid = uuid
            self.listener = listener
        }
    }
    
    public init(
        dateProvider: DateProvider,
        fileSystem: FileSystem,
        subprocess: Subprocess
    ) throws {
        automaticManagementItemControllers = subprocess.automaticManagement.items.map { item in
            AutomaticManagementItemController(dateProvider: dateProvider, item: item)
        }
        
        let arguments = try subprocess.arguments.map { try $0.stringValue() }
        processName = (arguments[0] as NSString).lastPathComponent
        process = try DefaultProcessController.createProcess(
            fileSystem: fileSystem,
            arguments: arguments,
            environment: subprocess.environment.values,
            workingDirectory: subprocess.workingDirectory
        )
        
        self.subprocess = subprocess
        self.fileSystem = fileSystem
        
        try setUpProcessListening()
    }
    
    private static func createProcess(
        fileSystem: FileSystem,
        arguments: [String],
        environment: [String: String],
        workingDirectory: AbsolutePath
    ) throws -> Process {
        let pathToExecutable = AbsolutePath(arguments[0])
        
        let executableProperties = fileSystem.properties(forFileAtPath: pathToExecutable)
        
        guard try executableProperties.isExecutable() else {
            throw ProcessControllerError.fileIsNotExecutable(path: pathToExecutable)
        }
        
        let process = Process()
        process.launchPath = pathToExecutable.pathString
        process.arguments = Array(arguments.dropFirst())
        process.environment = environment
        process.currentDirectoryPath = workingDirectory.pathString
        try process.setStartsNewProcessGroup(false)
        return process
    }
    
    public var description: String {
        let executable = process.launchPath ?? "unknown executable"
        let args = process.arguments?.joined(separator: " ") ?? ""
        return "<\(type(of: self)): \(executable) \(args) \(processStatus())>"
    }
    
    // MARK: - Launch and Kill
    
    public func start() throws {
        if didStartProcess {
            return
        }
        
        didStartProcess = true
        
        try process.run()

        processTerminationHandlerGroup.enter()
        process.terminationHandler = { _ in
            self.processTerminated()
        }
        processId = process.processIdentifier
        startAutomaticManagement()

        listenerQueue.async {
            for listenerWrapper in self.startListeners {
                let unsubscriber: Unsubscribe = {
                    self.listenerQueue.async {
                        self.startListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(self, unsubscriber)
            }
        }
    }
    
    public func waitForProcessToDie() {
        process.waitUntilExit()
        openPipeFileHandleGroup.wait()
        processTerminationHandlerGroup.wait()
    }
    
    public func processStatus() -> ProcessStatus {
        if !didStartProcess {
            return .notStarted
        }
        if process.isRunning {
            return .stillRunning
        }
        return .terminated(exitCode: process.terminationStatus)
    }
    
    public func send(signal: Int32) {
        listenerQueue.async {
            for listenerWrapper in self.signalListeners {
                let unsubscriber: Unsubscribe = {
                    self.listenerQueue.async {
                        self.signalListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(self, signal, unsubscriber)
            }
            kill(-self.processId, signal)
        }
    }
    
    public func terminateAndForceKillIfNeeded() {
        attemptToKillProcess { _ in
            send(signal: SIGTERM)
        }
    }
    
    public func interruptAndForceKillIfNeeded() {
        attemptToKillProcess { _ in
            send(signal: SIGINT)
        }
    }
    
    public func onStart(listener: @escaping StartListener) {
        startListeners.append(ListenerWrapper(uuid: UUID(), listener: listener))
    }
    
    public func onStdout(listener: @escaping StdoutListener) {
        stdoutListeners.append(ListenerWrapper(uuid: UUID(), listener: listener))
    }
    
    public func onStderr(listener: @escaping StderrListener) {
        stderrListeners.append(ListenerWrapper(uuid: UUID(), listener: listener))
    }
    
    public func onSignal(listener: @escaping SignalListener) {
        signalListeners.append(ListenerWrapper(uuid: UUID(), listener: listener))
    }
    
    public func onTermination(listener: @escaping TerminationListener) {
        terminationListeners.append(ListenerWrapper(uuid: UUID(), listener: listener))
    }
    
    private func attemptToKillProcess(killer: (Process) -> ()) {
        processTerminationQueue.sync {
            guard self.didInitiateKillOfProcess == false else { return }
            self.didInitiateKillOfProcess = true
            killer(process)
            processTerminationQueue.asyncAfter(deadline: .now() + 15.0) {
                self.forceKillProcess()
            }
        }
    }
    
    private func forceKillProcess() {
        if isProcessRunning {
            send(signal: SIGKILL)
        }
    }
    
    private func processTerminated() {
        listenerQueue.async {
            for listenerWrapper in self.terminationListeners {
                let unsubscriber: Unsubscribe = {
                    self.listenerQueue.async {
                        self.signalListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(self, unsubscriber)
            }
        }
        
        listenerQueue.async(flags: .barrier) {
            self.processTerminationHandlerGroup.leave()
            
            self.signalListeners.removeAll()
            self.startListeners.removeAll()
            self.stderrListeners.removeAll()
            self.stdoutListeners.removeAll()
            self.terminationListeners.removeAll()
        }
    }
    
    // MARK: - Hang Monitoring
    
    private func startAutomaticManagement() {
        automaticManagementTrackingTimer = DispatchBasedTimer.startedTimer(repeating: .seconds(1), leeway: .seconds(1)) { [weak self] timer in
            guard let strongSelf = self else { return timer.stop() }
            strongSelf.automaticManagementItemControllers.forEach { $0.fireEventIfNecessary(processController: strongSelf) }
        }
    }
    
    // MARK: - Processing Output
    
    private func streamFromPipeIntoHandle(
        pipe: Pipe,
        onNewData: @escaping (Data) -> (),
        onEndOfData: @escaping () -> ()
    ) {
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.isEmpty {
                handle.readabilityHandler = nil
                onEndOfData()
            } else {
                onNewData(data)
            }
        }
    }
    
    private func setUpProcessListening() throws {
        processStdForProcess(
            pipeAssigningClosure: { pipe in
                self.process.standardOutput = pipe
                self.openPipeFileHandleGroup.enter()
            },
            onNewData: didReceiveStdout,
            onEndOfData: {
                self.listenerQueue.async {
                    self.openPipeFileHandleGroup.leave()
                }
            }
        )
        
        processStdForProcess(
            pipeAssigningClosure: { pipe in
                self.process.standardError = pipe
                self.openPipeFileHandleGroup.enter()
            },
            onNewData: didReceiveStderr,
            onEndOfData: {
                self.listenerQueue.async {
                    self.openPipeFileHandleGroup.leave()
                }
            }
        )
    }
    
    private func processStdForProcess(
        pipeAssigningClosure: (Pipe) -> (),
        onNewData: @escaping (Data) -> (),
        onEndOfData: @escaping () -> ()
    ) {
        let pipe = Pipe()
        pipeAssigningClosure(pipe)
        streamFromPipeIntoHandle(
            pipe: pipe,
            onNewData: { data in
                self.didProcessDataFromProcess()
                onNewData(data)
            },
            onEndOfData: {
                onEndOfData()
            }
        )
    }
    
    private func didReceiveStdout(data: Data) {
        listenerQueue.async {
            for listenerWrapper in self.stdoutListeners {
                let unsubscriber: Unsubscribe = {
                    self.listenerQueue.async {
                        self.stdoutListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(self, data, unsubscriber)
            }
        }
    }
    
    private func didReceiveStderr(data: Data) {
        listenerQueue.async {
            for listenerWrapper in self.stderrListeners {
                let unsubscriber: Unsubscribe = {
                    self.listenerQueue.async {
                        self.stderrListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(self, data, unsubscriber)
            }
        }
    }
    
    private func didProcessDataFromProcess() {
        for controller in automaticManagementItemControllers {
            controller.processReportedActivity()
        }
    }
}
