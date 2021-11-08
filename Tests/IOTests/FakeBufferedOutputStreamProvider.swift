import Foundation
import IO

final class FakeBufferedOutputStreamProvider: OutputStreamProvider {
    let capacity: Int
    var data: Data

    init(capacity: Int) {
        self.capacity = capacity
        self.data = Data(capacity: capacity)
    }
    
    lazy var stream: OutputStream = {
        data.withUnsafeMutableBytes { (unsafeMutableRawBufferPointer: UnsafeMutableRawBufferPointer) in
            guard let base = unsafeMutableRawBufferPointer.baseAddress else {
                fatalError("Pointer does not have base address")
            }
            let ump: UnsafeMutablePointer<UInt8> = base.bindMemory(to: UInt8.self, capacity: capacity)
            return OutputStream(toBuffer: ump, capacity: capacity)
        }
    }()
    
    func createOutputStream() throws -> OutputStream {
        return stream
    }
}
