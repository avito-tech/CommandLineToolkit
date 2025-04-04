import Foundation
import Logging
import AtomicModels

private final actor ANSIConsoleHandlerStateHolder {
    private var isInInteractiveMode: Bool = false

    /// Tries to switch mode, returns success or failure
    @discardableResult
    private func switchInteractive(on: Bool) -> Bool {
        switch (isInInteractiveMode, on) {
        case (true, true):
            return false
        case (_, false):
            isInInteractiveMode = false
            return true
        case (false, true):
            isInInteractiveMode = true
            return true
        }
    }

    func performInInteractiveMode<Value>(
        file: StaticString,
        line: UInt,
        operation: () async throws -> Value
    ) async rethrows -> Value {
        guard switchInteractive(on: true) else {
            fatalError(
                    """
                    Some interactive component is already running.

                    This could happen if you tried to launch several interactive console components concurrently.
                    It's allowed only inside of `Console.task`.
                    """,
                    file: file,
                    line: line
            )
        }
        defer { switchInteractive(on: false) }

        return try await operation()
    }
}

extension ConsoleContext {
    private enum StateHolderKey: ConsoleContextKey {
        static let defaultValue: ANSIConsoleHandlerStateHolder = .init()
    }

    fileprivate var stateHolder: ANSIConsoleHandlerStateHolder {
        get { self[StateHolderKey.self] }
        set { self[StateHolderKey.self] = newValue }
    }
}

public struct ConsoleVerbositySettings {
    public var logLevel: Logger.Level
    public var verbose: Bool
    
    public init(logLevel: Logger.Level, verbose: Bool) {
        self.logLevel = logLevel
        self.verbose = verbose
    }
    
    public static let `default` = Self(
        logLevel: .info,
        verbose: false
    )
    
    public static let trace = Self(
        logLevel: .trace,
        verbose: false
    )
    
    public static let verbose = Self(
        logLevel: .trace,
        verbose: true
    )
}

extension ConsoleContext {
    private enum ConsoleVerbositySettingsKey: ConsoleContextKey {
        static let defaultValue: ConsoleVerbositySettings = .init(
            logLevel: .info,
            verbose: false
        )
    }

    public var verbositySettings: ConsoleVerbositySettings {
        get { self[ConsoleVerbositySettingsKey.self] }
        set { self[ConsoleVerbositySettingsKey.self] = newValue }
    }
}

/// Default ``ConsoleHandler`` used in console library
public final class ANSIConsoleHandler: ConsoleHandler {
    public static let shared: ANSIConsoleHandler = .init()

    /// Frames per second which interactive console will try to perform
    static let targetFps: UInt64 = 30
    /// Tick delay in milliseconds
    static let tickDelayMs: UInt64 = UInt64((1.0 / Double(targetFps)) * 1000)
    /// Tick delay in nanoseconds
    static let tickDelayNs: UInt64 = tickDelayMs * 1_000_000

    /// Backing log handler for all messages.
    let backing: LogHandler?
    
    let terminal: ANSITerminal

    public var isAtTTY: Bool {
        return isatty(STDOUT_FILENO) > 0
    }

    public var isInteractive: Bool {
        isAtTTY && !ProcessInfo.processInfo.isRunningInXcode
    }

    public var verbositySettings: ConsoleVerbositySettings
    
    public init(
        terminal: ANSITerminal = .shared,
        verbositySettings: ConsoleVerbositySettings = .default,
        backing: LogHandler? = nil
    ) {
        self.terminal = terminal
        self.verbositySettings = verbositySettings
        self.backing = backing
    }

    enum ConsoleHandlerError: Error {
        case eventStreamFinished
        case componentFinishedWithoutResult
        case notAtTTY
        case noActiveTrace
    }

    struct RenderingState {
        var lastRender: ConsoleRender
        var lastRenderedLines: Int
        var fullRender: Bool = true
        var terminalSize: Size {
            willSet {
                fullRender = newValue != terminalSize
            }
        }
        var lastRenderCursorPos: Position
        var frame: Int = 0
        let frames: [String] = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    }

    func run<Value, Component: ConsoleComponent<Value>>(
        _ component: Component,
        file: StaticString,
        line: UInt
    ) async throws -> Value {
        try await ConsoleContext.$current.withUpdated(key: \.verbositySettings, value: verbositySettings) {
            if let activeContainer = ConsoleContext.current.activeContainer {
                activeContainer.add(child: component)
                while component.isUnfinished {
                    try await Task.sleep(nanoseconds: ANSIConsoleHandler.tickDelayNs)
                }
                guard let result = component.result else {
                    throw ConsoleHandlerError.componentFinishedWithoutResult
                }
                return try result.get()
            }

            return try await ConsoleContext.current.stateHolder.performInInteractiveMode(file: file, line: line) {
                var state: RenderingState = .init(
                    lastRender: .empty,
                    lastRenderedLines: 0,
                    terminalSize: terminal.size,
                    lastRenderCursorPos: terminal.readCursorPos()
                )

                if isInteractive {
                    terminal.enableNonBlockingTerminal()
                    defer { terminal.disableNonBlockingTerminal() }

                    repeat {
                        guard let event = getControlEvent(state: &state) else {
                            continue
                        }

                        component.handle(event: event)

                        if component.isVisible {
                            let renderer = component.renderer()
                            state.terminalSize = terminal.size
                            render(component: renderer.render(preferredSize: state.terminalSize), state: &state)
                        }
                        
                        if case .tick = event {
                            await Task.nonThrowingSleep(nanoseconds: ANSIConsoleHandler.tickDelayNs)
                        }
                    } while component.isUnfinished
                }

                if component.isVisible {
                    finalize(component: component, state: state)
                }

                guard let result = component.result else {
                    throw ConsoleHandlerError.componentFinishedWithoutResult
                }

                return try result.get()
            }
        }
    }

    private func finalize<Value, Component: ConsoleComponent<Value>>(
        component: Component,
        state: RenderingState
    ) {
        cleanLastRender(state: state)
        let renderer = component.renderer()
        renderNonInteractive(component: renderer.render(preferredSize: state.terminalSize))
    }

    private func cleanLastRender(state: RenderingState) {
        moveToRenderStart(state: state)
        terminal.clearBelow()
    }

    private func moveToRenderStart(state: RenderingState) {
        let linesToMoveUp: Int
        if let position = state.lastRender.cursorPosition {
            linesToMoveUp = position.row
        } else {
            linesToMoveUp = state.lastRenderedLines
        }

        if linesToMoveUp > 0 {
            terminal.moveUp(linesToMoveUp)
        }
        terminal.moveToColumn(1)
    }

    private func getControlEvent(state: inout RenderingState) -> ConsoleControlEvent? {
        let event: ConsoleControlEvent
        if terminal.keyPressed() {
            let char = terminal.readChar()
            switch char {
            case .escape:
                let sequence = terminal.readEscapeSequence()
                switch sequence {
                case let .key(code, meta):
                    event = .inputEscapeSequence(code: code, meta: meta)
                case .cursor:
                    return nil
                case let .screen(size):
                    if size != state.terminalSize {
                        state.terminalSize = size
                        state.fullRender = true
                    }
                    return nil
                case .unknown(raw: .ESC):
                    event = .inputChar(.escape)
                case let .unknown(raw):
                    fatalError("Unknown command \(raw.replacingOccurrences(of: String.ESC, with: "^"))")
                }
            default:
                event = .inputChar(char)
            }
        } else {
            event = .tick
        }

        return event
    }

    private func render(component: ConsoleRender, state: inout RenderingState) {
        terminal.cursorOff()
        moveToRenderStart(state: state)

        let newActualLines = component.lines.count
        let linesToRender = min(state.terminalSize.rows - 1, newActualLines)
        let firstLineToRender = newActualLines - linesToRender

        for line in firstLineToRender ..< newActualLines {
            let lineToRender = component.lines[line]
            let oldLine = state.lastRenderedLines - state.lastRender.lines.count + line
            if state.lastRender.lines.indices.contains(oldLine) && lineToRender == state.lastRender.lines[oldLine] && !state.fullRender {
                terminal.moveDown()
            } else {
                terminal.write(lineToRender.trimmed(to: state.terminalSize.cols).terminalStylize())
                terminal.clearToEndOfLine()
                terminal.writeln()
            }
        }
        let frame = state.frames[Int((Double(state.frame) / Double(ANSIConsoleHandler.targetFps)) * Double(state.frames.count)) % state.frames.count]
        terminal.write(Task.isCancelled ? "Завершаем задачу \(frame)" : frame)
        terminal.clearBelow()

        state.lastRenderCursorPos.row += -state.lastRenderedLines + linesToRender
        state.lastRenderCursorPos.row = min(state.terminalSize.rows, state.lastRenderCursorPos.row)
        state.lastRender = component
        state.lastRenderedLines = linesToRender
        state.fullRender = false
        state.frame = (state.frame + 1) % Int(ANSIConsoleHandler.targetFps)

        if let position = component.cursorPosition {
            terminal.moveUp(linesToRender - position.row + (newActualLines - linesToRender))
            terminal.moveToColumn(position.col)
            terminal.cursorOn()
        }
    }

    func renderNonInteractive(component: ConsoleRender) {
        for line in component.lines {
            if isInteractive {
                terminal.writeln(line.terminalStylize())
            } else {
                terminal.writeln(line.description)
            }
            backing?.log(
                level: verbositySettings.logLevel,
                message: "\(line.description)", 
                metadata: nil,
                source: "component",
                file: #fileID,
                function: #function,
                line: #line
            )
        }
        if isInteractive {
            terminal.cursorOn()
        }
    }
}

private extension Task where Success == Never, Failure == Never {
    static func nonThrowingSleep(nanoseconds: UInt64) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(
                deadline: .now() + .nanoseconds(Int(nanoseconds)),
                execute: continuation.resume
            )
        }
    }
}

enum ConsoleControlEvent {
    case tick
    case inputChar(Character)
    case inputEscapeSequence(code: ANSIKeyCode, meta: [ANSIMetaCode])
}

protocol ConsoleComponent<Value> {
    associatedtype Value = Void
    associatedtype ComponentRenderer: Renderer<Void>
    
    /// Result of component execution
    var result: Result<Value, Error>? { get }
    
    /// Is component visible at current global logging verbosity settings
    var isVisible: Bool { get }
    
    /// If component can be collapsed (hidden) in current trace
    /// - Parameter level: Level of current trace
    func canBeCollapsed(at level: Logger.Level) -> Bool
    
    /// Handle input or lifecycle event
    /// - Parameter event: event to handle
    func handle(event: ConsoleControlEvent)
    
    /// Produce rendeder with baked current state
    func renderer() -> ComponentRenderer
}

extension ConsoleComponent {
    func typeErasedRenderer() -> AnyRenderer<Void> {
        renderer().asAnyRenderer
    }
}

protocol Renderer<State> {
    associatedtype State
    func render(state: State, preferredSize: Size?) -> ConsoleRender
}

extension Renderer where State == Void {
    func render(preferredSize: Size?) -> ConsoleRender {
        render(state: (), preferredSize: preferredSize)
    }
}

struct AnyRenderer<State>: Renderer {
    let renderUpstream: (State, Size?) -> ConsoleRender

    init<Upstream: Renderer>(upstream: Upstream) where Upstream.State == State {
        renderUpstream = { state, preferredSize in
            upstream.render(state: state, preferredSize: preferredSize)
        }
    }

    func render(state: State, preferredSize: Size?) -> ConsoleRender {
        renderUpstream(state, preferredSize)
    }
}

extension Renderer {
    var asAnyRenderer: AnyRenderer<State> {
        AnyRenderer(upstream: self)
    }
}

struct LRUCache<Key: Hashable, Value> {
    private let size: Int
    private var values: [Key: Value] = [:]
    private var keyQueue: [Key] = []
    private var keyIndex: [Key: Int] = [:]

    init(size: Int) {
        self.size = size
    }

    mutating func refer(to key: Key, value valueFactory: () -> Value) -> Value {
        if let keyCacheIndex = keyIndex[key], let value = values[key] {
            keyQueue.remove(at: keyCacheIndex)
            keyQueue.insert(key, at: 0)
            keyIndex[key] = 0
            return value
        }

        if keyQueue.count >= size {
            let lastKey = keyQueue.removeLast()
            keyIndex.removeValue(forKey: lastKey)
            values.removeValue(forKey: lastKey)
        }

        let value = valueFactory()

        keyQueue.insert(key, at: 0)
        keyIndex[key] = 0
        values[key] = value

        return value
    }
}

enum RenderCache {
    struct Key: Hashable {
        let state: AnyHashable
        let preferredSize: Size?

        init<State: Hashable>(state: State, preferredSize: Size?) {
            self.state = AnyHashable(state)
            self.preferredSize = preferredSize
        }
    }
    static var cache = AtomicValue(LRUCache<Key, ConsoleRender>(size: 500))
}

struct CachedRenderer<Upstream: Renderer>: Renderer where Upstream.State: Hashable {
    let upstream: Upstream

    func render(state: Upstream.State, preferredSize: Size?) -> ConsoleRender {
        RenderCache.cache.withExclusiveAccess { cache in
            cache.refer(to: .init(state: state, preferredSize: preferredSize)) {
                upstream.render(state: state, preferredSize: preferredSize)
            }
        }
    }
}

extension Renderer where State: Hashable {
    func withCache() -> some Renderer<State> {
        CachedRenderer(upstream: self)
    }
}

struct BakedStateRenderer<Upstream: Renderer>: Renderer  {
    let upstream: Upstream
    let bakedState: Upstream.State

    func render(state: Void, preferredSize: Size?) -> ConsoleRender {
        upstream.render(state: bakedState, preferredSize: preferredSize)
    }
}

extension Renderer {
    func withState(state: State) -> some Renderer<Void> {
        BakedStateRenderer(upstream: self, bakedState: state)
    }
}

extension ConsoleComponent {
    var isFinished: Bool {
        result != nil
    }

    var isUnfinished: Bool {
        result == nil
    }
    
    var isFailure: Bool {
        if case .failure = result { true } else { false }
    }
    
    var isSuccess: Bool {
        if case .success = result { true } else { false }
    }
}

protocol ContainerConsoleComponent: AnyObject {
    var parent: ContainerConsoleComponent? { get set }
    var children: [any ConsoleComponent] { get }

    func add(child: any ConsoleComponent)
}

struct ConsoleRender {
    /// Component textual layout
    var lines: [ConsoleText]

    var cursorPosition: Position?

    var actualLineCount: Int {
        lines.lazy
            .map { $0.fragments.map(\.string).joined() }
            .flatMap { $0.components(separatedBy: .newlines) }
            .count
    }

    static let empty: Self = .init(lines: [])
}

extension ProcessInfo {
    fileprivate var isRunningInXcode: Bool {
        // Xcode doesn't set these vars
        environment["TERM"] == nil && environment["TERM_PROGRAM"] == nil
    }
}
