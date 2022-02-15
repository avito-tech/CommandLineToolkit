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
    
    private final class ListenerWrapper<T>: CustomStringConvertible {
        let uuid: UUID
        let purpose: String
        let listener: T

        init(uuid: UUID, purpose: String, listener: T) {
            self.uuid = uuid
            self.purpose = purpose
            self.listener = listener
        }
        
        var description: String { "<\(type(of: self)) purpose: \(purpose) listener: \(listener)>" }
    }
    
    public init(
        dateProvider: DateProvider,
        filePropertiesProvider: FilePropertiesProvider,
        subprocess: Subprocess
    ) throws {
        automaticManagementItemControllers = subprocess.automaticManagement.items.map { item in
            AutomaticManagementItemController(dateProvider: dateProvider, item: item)
        }
        
        let arguments = try subprocess.arguments.map { try $0.stringValue() }
        processName = (arguments[0] as NSString).lastPathComponent
        process = try DefaultProcessController.createProcess(
            filePropertiesProvider: filePropertiesProvider,
            arguments: arguments,
            environment: subprocess.environment.values,
            workingDirectory: subprocess.workingDirectory
        )
        
        self.subprocess = subprocess
        
        try setUpProcessListening()
    }
    
    private static func createProcess(
        filePropertiesProvider: FilePropertiesProvider,
        arguments: [String],
        environment: [String: String],
        workingDirectory: AbsolutePath
    ) throws -> Process {
        let pathToExecutable = AbsolutePath(arguments[0])
        
        let executableProperties = filePropertiesProvider.properties(forFileAtPath: pathToExecutable)
        
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
        process.terminationHandler = { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.processTerminated()
        }
        processId = process.processIdentifier
        startAutomaticManagement()

        listenerQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            
            for listenerWrapper in strongSelf.startListeners {
                let unsubscriber: Unsubscribe = { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.listenerQueue.async {
                        strongSelf.startListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(strongSelf, unsubscriber)
            }
        }
    }
    
    public func waitForProcessToDie() {
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
        listenerQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            
            for listenerWrapper in strongSelf.signalListeners {
                let unsubscriber: Unsubscribe = { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.listenerQueue.async {
                        strongSelf.signalListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(strongSelf, signal, unsubscriber)
            }
            kill(-strongSelf.processId, signal)
        }
    }
    
    public func signalAndForceKillIfNeeded(
        terminationSignal: Int32,
        terminationSignalTimeout: TimeInterval,
        onKill: @escaping () -> ()
    ) {
        attemptToKillProcess(
            signalTermination: { _ in send(signal: terminationSignal) },
            terminationSignalTimeout: terminationSignalTimeout,
            onKill: onKill
        )
    }
    
    public func onStart(listener: @escaping StartListener) {
        startListeners.append(ListenerWrapper(uuid: UUID(), purpose: "onStart", listener: listener))
    }
    
    public func onStdout(listener: @escaping StdoutListener) {
        stdoutListeners.append(ListenerWrapper(uuid: UUID(), purpose: "onStdout", listener: listener))
    }
    
    public func onStderr(listener: @escaping StderrListener) {
        stderrListeners.append(ListenerWrapper(uuid: UUID(), purpose: "onStderr", listener: listener))
    }
    
    public func onSignal(listener: @escaping SignalListener) {
        signalListeners.append(ListenerWrapper(uuid: UUID(), purpose: "onSignal", listener: listener))
    }
    
    public func onTermination(listener: @escaping TerminationListener) {
        terminationListeners.append(ListenerWrapper(uuid: UUID(), purpose: "onTermination", listener: listener))
    }
    
    private func attemptToKillProcess(
        signalTermination: (Process) -> (),
        terminationSignalTimeout: TimeInterval,
        onKill: @escaping () -> ()
    ) {
        processTerminationQueue.sync {
            guard didInitiateKillOfProcess == false else { return }
            didInitiateKillOfProcess = true
            signalTermination(process)
            processTerminationQueue.asyncAfter(deadline: .now() + terminationSignalTimeout) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.forceKillProcess(onKill: onKill)
            }
        }
    }
    
    private func forceKillProcess(onKill: () -> ()) {
        if isProcessRunning {
            onKill()
            send(signal: SIGKILL)
        }
    }
    
    private func processTerminated() {
        listenerQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            
            for listenerWrapper in strongSelf.terminationListeners {
                let unsubscriber: Unsubscribe = { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.listenerQueue.async {
                        strongSelf.signalListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(strongSelf, unsubscriber)
            }
        }
        
        listenerQueue.async(flags: .barrier) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.processTerminationHandlerGroup.leave()
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
                pipe.fileHandleForReading.closeFile()
                onEndOfData()
            } else {
                onNewData(data)
            }
        }
    }
    
    private func setUpProcessListening() throws {
        processStdForProcess(
            pipeAssigningClosure: { pipe in
                process.standardOutput = pipe
                openPipeFileHandleGroup.enter()
            },
            onNewData: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.didReceiveStdout(data: data)
            },
            onEndOfData: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.listenerQueue.async {
                    strongSelf.openPipeFileHandleGroup.leave()
                }
            }
        )
        
        processStdForProcess(
            pipeAssigningClosure: { pipe in
                process.standardError = pipe
                openPipeFileHandleGroup.enter()
            },
            onNewData: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.didReceiveStderr(data: data)
            },
            onEndOfData: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.listenerQueue.async {
                    strongSelf.openPipeFileHandleGroup.leave()
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
            onNewData: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.didProcessDataFromProcess()
                onNewData(data)
            },
            onEndOfData: onEndOfData
        )
    }
    
    private func didReceiveStdout(data: Data) {
        listenerQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            
            for listenerWrapper in strongSelf.stdoutListeners {
                let unsubscriber: Unsubscribe = { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.listenerQueue.async {
                        strongSelf.stdoutListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(strongSelf, data, unsubscriber)
            }
        }
    }
    
    private func didReceiveStderr(data: Data) {
        listenerQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            
            for listenerWrapper in strongSelf.stderrListeners {
                let unsubscriber: Unsubscribe = { [weak self] in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.listenerQueue.async {
                        strongSelf.stderrListeners.removeAll { $0.uuid == listenerWrapper.uuid }
                    }
                }
                listenerWrapper.listener(strongSelf, data, unsubscriber)
            }
        }
    }
    
    private func didProcessDataFromProcess() {
        for controller in automaticManagementItemControllers {
            controller.processReportedActivity()
        }
    }
}
