import Graphite
import Statsd

public protocol MutableMetricRecorder: MetricRecorder {
    func setGraphiteMetric(handler: GraphiteMetricHandler) throws
    func setStatsdMetric(handler: StatsdMetricHandler) throws
}
