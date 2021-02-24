import AtomicModels
import Foundation
import IO
import Network
import SocketModels

public final class StatsdMetricHandlerImpl: StatsdMetricHandler {
    private let statsdDomain: [String]
    private let statsdClient: StatsdClient
    private let serialQueue: DispatchQueue
    
    private let metricsBuffer = AtomicCollection([StatsdMetric]())
    private let metricsBeingSent = AtomicCollection([UUID]())
    
    public init(
        statsdDomain: [String],
        statsdClient: StatsdClient,
        serialQueue: DispatchQueue = DispatchQueue(label: "StatsdMetricHandlerImpl.serialQueue")
    ) throws {
        self.statsdDomain = statsdDomain
        self.statsdClient = statsdClient
        self.serialQueue = serialQueue
        
        self.statsdClient.stateUpdateHandler = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .setup:
                break
            case .waiting:
                break
            case .preparing:
                break
            case .ready:
                self.metricsBuffer.withExclusiveAccess {
                    $0.forEach(self.send)
                    $0.removeAll()
                }
            case .failed:
                self.statsdClient.cancel()
            case .cancelled:
                break
            @unknown default:
                break
            }
        }
        statsdClient.start(queue: serialQueue)
    }
    
    public func handle(metric: StatsdMetric) {
        // swiftlint:disable:next async
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            let state = self.statsdClient.state
            switch state {
            case .cancelled, .failed:
                break
            case .waiting, .preparing, .setup:
                self.metricsBuffer.withExclusiveAccess { $0.append(metric) }
            case .ready:
                self.send(metric: metric)
            @unknown default:
                break
            }
        }
    }
    
    public func tearDown(timeout: TimeInterval) {
        let tearDownRequestTimestamp = Date()
        _ = metricsBuffer.waitWhen(count: 0, before: tearDownRequestTimestamp.addingTimeInterval(timeout))
        
        let timeoutRemainder = timeout - Date().timeIntervalSince(tearDownRequestTimestamp)
        if timeoutRemainder > 0 {
            _ = metricsBeingSent.waitWhen(count: 0, before: Date(timeIntervalSinceNow: timeoutRemainder))
        }
        
        statsdClient.cancel()
    }
    
    private func send(metric: StatsdMetric) {
        let seed = UUID()
        metricsBeingSent.withExclusiveAccess { $0.append(seed) }
        self.statsdClient.send(
            content: Data(metric.build(domain: self.statsdDomain).utf8)
        ) { _ in
            self.metricsBeingSent.withExclusiveAccess {
                $0.removeAll(where: { $0 == seed })
            }
        }
    }
}
