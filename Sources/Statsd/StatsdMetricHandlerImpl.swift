import AtomicModels
import Foundation
import SocketModels

public final class StatsdMetricHandlerImpl: StatsdMetricHandler {
    private let statsdDomain: [String]
    private let statsdClient: StatsdClient
    private let serialQueue: DispatchQueue
    private let group = DispatchGroup()
    
    public init(
        statsdDomain: [String],
        statsdClient: StatsdClient,
        serialQueue: DispatchQueue = DispatchQueue(label: "StatsdMetricHandlerImpl.serialQueue")
    ) throws {
        self.statsdDomain = statsdDomain
        self.statsdClient = statsdClient
        self.serialQueue = serialQueue
    }
    
    public func handle(metric: StatsdMetric) {
        let metricData = Data(metric.build(domain: self.statsdDomain).utf8)
        
        group.enter()
        
        statsdClient.send(
            content: metricData,
            queue: serialQueue
        ) { [group] _ in
            group.leave()
        }
    }
    
    public func tearDown(timeout: TimeInterval) {
        group.enter()
        
        statsdClient.tearDown(
            queue: serialQueue,
            timeout: timeout,
            completion: { [group] in
                group.leave()
            }
        )
        
        _ = group.wait(timeout: .now() + timeout)
    }
}
