import Dispatch
import Foundation
import Signals
import Types

public typealias SignalHandler = (Int32) -> ()

private let syncQueue = DispatchQueue(label: "SignalHandling.syncQueue")
private var signalHandlers = [Int32: [UUID: SignalHandler]]()

// swiftlint:disable sync

public final class SignalHandling {
    public struct Handle {
        var signal: Int32
        var id: UUID
    }

    private init() {}

    /// Captures and holds a given handler and invokes it when a required signal occurs.
    @discardableResult
    public static func addSignalHandler(signal: Signal, handler: @escaping SignalHandler) -> Handle {
        let id = UUID()
        
        syncQueue.sync {
            signalHandlers[signal.intValue, default: [:]][id] = handler
        }
        
        Signals.trap(signal: signal.blueSignal) { signalValue in
            _handleSignal(signalValue)
        }

        return Handle(signal: signal.intValue, id: id)
    }

    public static func removeSignalHandler(handle: Handle) {
        syncQueue.sync {
            signalHandlers[handle.signal]?[handle.id] = nil
        }
    }

    public static func listen(signal: Signal) -> AsyncStream<Signal> {
        AsyncStream { continuation in
            let handle = addSignalHandler(signal: signal) { signal in
                continuation.yield(.init(rawValue: signal))
            }

            continuation.onTermination = { _ in
                removeSignalHandler(handle: handle)
            }
        }
    }
}

/// Universal signal handler
private func _handleSignal(_ signalValue: Int32) {
    let registeredHandlers = syncQueue.sync { signalHandlers[signalValue, default: [:]] }
    for (_, handler) in registeredHandlers {
        handler(signalValue)
    }
}
