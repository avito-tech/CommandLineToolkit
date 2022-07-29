@testable import GraphiteClient
import AtomicModels
import IO
import XCTest

final class GraphiteClientTests: XCTestCase {
#if os(macOS)
    func disabled___test___simple_use_case() throws {
        let stream = AppleEasyOutputStream(
            outputStreamProvider: AppleNetworkSocketOutputStreamProvider(host: "host", port: 65432),
            batchSize: 1024,
            errorHandler: { _, error in
                XCTFail("Unexpected error: \(error)")
            },
            streamEndHandler: { _ in }
        )
        try stream.open()
        
        let client = GraphiteClient(easyOutputStream: stream)
        try client.send(path: ["some", "test", "metric"], value: 12.767, timestamp: Date())
        
        XCTAssertEqual(stream.waitAndClose(timeout: 5), .successfullyFlushedInTime)
    }
#endif
}
