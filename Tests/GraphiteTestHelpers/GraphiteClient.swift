import Foundation
import Graphite

open class FakeGraphiteMetricHandler: GraphiteMetricHandler {
    public var handleClosure: (GraphiteMetric) -> ()
    public var tearDownClosure: (TimeInterval) -> ()

    public init(
        handleClosure: @escaping (GraphiteMetric) -> () = { _ in },
        tearDownClosure: @escaping (TimeInterval) -> () = { _ in }
    ) {
        self.handleClosure = handleClosure
        self.tearDownClosure = tearDownClosure
    }
    
    public func handle(metric: GraphiteMetric) {
        handleClosure(metric)
    }
    
    public func tearDown(timeout: TimeInterval) {
        tearDownClosure(timeout)
    }
}
