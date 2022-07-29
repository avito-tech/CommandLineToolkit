import Foundation
import IO

#if os(macOS)
final class BoundStreamsOutputStreamProvider: OutputStreamProvider {
    
    let inputStream: InputStream
    let outputStream: OutputStream
    
    init(bufferSize: Int = 1024) {
        var boundInputStream: InputStream?
        var boundOutputStream: OutputStream?
        Stream.getBoundStreams(
            withBufferSize: bufferSize,
            inputStream: &boundInputStream,
            outputStream: &boundOutputStream
        )
        guard let providedInputStream = boundInputStream, let providedOutputStream = boundOutputStream else {
            fatalError("Either input, or output, or both input and output streams are nil")
        }
        
        inputStream = providedInputStream
        outputStream = providedOutputStream
    }
    
    func createOutputStream() throws -> OutputStream {
        return outputStream
    }
}
#endif
