import Graphite
import MetricsRecording

public extension GraphiteMetric {
    func testCompare(_ other: GraphiteMetric) -> Bool {
        return self.components == other.components
            && self.value == other.value
    }
}
