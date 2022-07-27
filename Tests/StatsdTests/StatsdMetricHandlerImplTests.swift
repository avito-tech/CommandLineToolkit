import Foundation
import MetricsRecording
import Statsd
import XCTest

final class StatsdMetricHandlerImplTests: XCTestCase {
    lazy var queue = DispatchQueue(label: "test")
    
    func test___handler___doesnt_send_metrics___in_non_ready_states() throws {
        let states: [StatsdClientState] = [
            .notReady,
            .failed,
        ]
        
        try states.forEach { state in
            let client = FakeStatsdClient(initialState: state)
            let handler = try StatsdMetricHandlerImpl(
                statsdDomain: ["domain"],
                statsdClient: client,
                serialQueue: queue
            )
            
            handler.handle(metric: metric())
            
            // swiftlint:disable:next sync
            queue.sync {}
            XCTAssertTrue(client.sentData.isEmpty)
        }
    }
    
    func test___handler___sends_metric___in_ready_state() throws {
        let client = FakeStatsdClient(initialState: .ready)
        let handler = try StatsdMetricHandlerImpl(
            statsdDomain: ["domain"],
            statsdClient: client,
            serialQueue: queue
        )
        
        handler.handle(metric: metric())
        
        // swiftlint:disable:next sync
        queue.sync {}
        XCTAssertEqual(
            client.sentData,
            [Data("domain.a.b:1000|ms".utf8)]
        )
    }
    
    func test___handler___buffers_metrics___untill_in_ready_state() throws {
        let states: [StatsdClientState] = [
            .notReady,
        ]
        
        try states.forEach { state in
            let client = FakeStatsdClient(initialState: state)
            let handler = try StatsdMetricHandlerImpl(
                statsdDomain: ["domain"],
                statsdClient: client,
                serialQueue: queue
            )
            
            handler.handle(metric: metric())
            
            // swiftlint:disable:next async
            queue.async { client.update(state: .ready) }
            
            // swiftlint:disable:next sync
            queue.sync {}
            XCTAssertEqual(
                client.sentData,
                [Data("domain.a.b:1000|ms".utf8)]
            )
        }
    }
    
    func test___tear_down_empties_all_buffers() throws {
        let client = FakeStatsdClient(initialState: .ready)
        let handler = try StatsdMetricHandlerImpl(
            statsdDomain: ["domain"],
            statsdClient: client,
            serialQueue: queue
        )
        
        var metricsToBeSent = [(data: Data, completion: (Error?) -> ())]()
        
        let enqueuedMetricsForSending = XCTestExpectation(description: "Metric enqueued for sending")
        client.onSend = { (data: Data, callback: @escaping (Error?) -> ()) in
            metricsToBeSent.append(
                (data: data, completion: callback)
            )
            enqueuedMetricsForSending.fulfill()
        }
        handler.handle(metric: metric())
        wait(for: [enqueuedMetricsForSending], timeout: 10)
        
        let teardownUnexpectedCompletionExpectation = XCTestExpectation(description: "teardown finished unexpectedly")
        teardownUnexpectedCompletionExpectation.isInverted = true
        
        let teardownCompletionExpectation = XCTestExpectation(description: "teardown finished")
        
        let connectionCancelledExpectation = XCTestExpectation(description: "connection should be cancelled")
        client.stateUpdateHandler = { targetState in
            if targetState == .notReady {
                connectionCancelledExpectation.fulfill()
            }
        }
        
        let impactQueue = DispatchQueue(label: "impact", attributes: .concurrent)
        
        // swiftlint:disable:next async
        impactQueue.async {
            handler.tearDown(timeout: 15)
            teardownUnexpectedCompletionExpectation.fulfill()
            teardownCompletionExpectation.fulfill()
        }
        
        wait(for: [teardownUnexpectedCompletionExpectation], timeout: 1)
        
        for metricToSend in metricsToBeSent {
            metricToSend.completion(nil)
        }
        wait(for: [teardownCompletionExpectation, connectionCancelledExpectation], timeout: 5)
    }
    
    private func metric() -> StatsdMetric {
        StatsdMetric(fixedComponents: ["a"], variableComponents: ["b"], value: .time(1))
    }
}
