import Logging

public struct ConsoleLogHandler: LogHandler {
    private let handler: ConsoleHandler

    public var logLevel: Logger.Level
    public var metadata: Logger.Metadata = [:]

    public init(handler: ConsoleHandler, label: String) {
        self.handler = handler
        self.logLevel = handler.logLevel
    }

    public init(console: Console = .init(), label: String) {
        self.init(handler: console.handler, label: label)
    }

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    public func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        let fullMetadata: Logger.Metadata

        if let metadata {
            fullMetadata = self.metadata.merging(metadata) { $1 }
        } else {
            fullMetadata = self.metadata
        }

        handler.log(
            level: level,
            message: message,
            metadata: fullMetadata,
            source: source,
            file: file,
            function: function,
            line: line
        )
    }
}
