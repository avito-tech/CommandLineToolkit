import Foundation

#if os(macOS)
public final class AppleNetworkSocketOutputStreamProvider: OutputStreamProvider {
    private let host: String
    private let port: Int
    
    public enum Error: Swift.Error, CustomStringConvertible {
        case failedToObtainOutputStream(String, Int)
        
        public var description: String {
            switch self {
            case let .failedToObtainOutputStream(host, port):
                return "Failed to obtain output stream to \(host):\(port)"
            }
        }
    }
    
    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    public func createOutputStream() throws -> OutputStream {
        var generatedOutputStream: OutputStream?
        Stream.getStreamsToHost(
            withName: host,
            port: port,
            inputStream: nil,
            outputStream: &generatedOutputStream
        )
        guard let outputStream = generatedOutputStream else {
            throw Error.failedToObtainOutputStream(host, port)
        }
        return outputStream
    }
}
#endif