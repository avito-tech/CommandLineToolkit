import Foundation
import GraphiteClient
import IO
import MetricsUtils
import SocketModels

public final class GraphiteMetricHandlerImpl: GraphiteMetricHandler {
    private let graphiteDomain: [String]
    private let outputStream: EasyOutputStream
    private let graphiteClient: GraphiteClient
    
    public init(
        graphiteDomain: [String],
        graphiteSocketAddress: SocketAddress
    ) throws {
        self.graphiteDomain = graphiteDomain
        
        let streamReopener = StreamReopener(maximumAttemptsToReopenStream: 10)
        
        outputStream = EasyOutputStream(
            outputStreamProvider: NetworkSocketOutputStreamProvider(
                host: graphiteSocketAddress.host,
                port: graphiteSocketAddress.port.value
            ),
            errorHandler: { stream, _ in
                streamReopener.attemptToReopenStream(stream: stream)
            },
            streamEndHandler: { stream in
                streamReopener.attemptToReopenStream(stream: stream)
            }
        )
        
        streamReopener.streamHasBeenOpened()
        try outputStream.open()
        self.graphiteClient = GraphiteClient(easyOutputStream: outputStream)
    }
    
    public func handle(metric: GraphiteMetric) {
        do {
            try graphiteClient.send(
                path: graphiteDomain + metric.components,
                value: metric.value,
                timestamp: metric.timestamp
            )
        } catch {
//            Logger.warning("Failed to send metric \(metric) to graphite: \(error)")
        }
    }
    
    public func tearDown(timeout: TimeInterval) {
        let result = outputStream.waitAndClose(timeout: timeout)
        if result == .flushTimeout {
//            Logger.warning("Failed to tear down in time")
        }
    }
}
