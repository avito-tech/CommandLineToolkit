import Foundation

public final class JSONStreamFactory {
    
    public struct JSONStreamParts {
        /// Write your incoming bytes from your source into this appendable stream.
        /// Your source could be a socket, a file, etc.
        /// You can append to this object from a background thread or queue.
        /// You should not read from this stream, you should only write to it.
        /// When your source of bytes ends (e.g. on EOF, or when socket is closed), call `close()` on this appendable stream.
        /// By closing this stream, you are stating that there no more bytes will be appended to this stream,
        /// allowing `JSONReader` to finish its continous parse operation.
        public let appendableStream: AppendableJSONStream
        
        /// Call `start()` on this reader to initiate recursive, blocking, and continous parse of your byte stream.
        /// As a result, `start()` method will either throw an error if stream error occur (e.g. broken data, unexpected values, etc.),
        /// or it will return without throwing errors.
        /// Since `start()` call is blocking, you can call it on your own queue/thread.
        public let jsonReader: JSONReader
    }
    
    /// Creates a structure of objects to allow running your JSON stream.
    /// - Parameter eventStream: This object is responsible for processing all parsed JSON objects.
    /// Consider it as a delegate of a JSON stream. This is where you get events about parsed objects.
    /// - Returns: `JSONStreamParts` object, with `appendableStream` object (you feed it with your incoming bytes),
    /// and `jsonReader` object (actual parser) configured to work together.
    public static func create(
        eventStream: JSONReaderEventStream
    ) -> JSONStreamParts {
        let jsonStream: AppendableJSONStream = BlockingArrayBasedJSONStream()
        let jsonReader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        return JSONStreamParts(appendableStream: jsonStream, jsonReader: jsonReader)
    }
}
