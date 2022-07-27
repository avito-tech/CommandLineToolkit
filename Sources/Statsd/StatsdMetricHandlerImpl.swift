import AtomicModels
import Foundation
import IO
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
            guard let strongSelf = self else { return }
            
            switch state {
            case .notReady:
                break
            case .ready:
                strongSelf.metricsBuffer.withExclusiveAccess {
                    $0.forEach(strongSelf.send)
                    $0.removeAll()
                }
            case .failed:
                strongSelf.statsdClient.cancel()
            }
        }
        statsdClient.start(queue: serialQueue)
    }
    
    public func handle(metric: StatsdMetric) {
        // swiftlint:disable:next async
        serialQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            let state = strongSelf.statsdClient.state
            
            switch state {
            case .notReady:
                strongSelf.metricsBuffer.withExclusiveAccess { $0.append(metric) }
            case .ready:
                strongSelf.send(metric: metric)
            case .failed:
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
