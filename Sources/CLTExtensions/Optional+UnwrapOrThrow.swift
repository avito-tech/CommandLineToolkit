extension Optional {
    public func unwrapOrThrow(
        error: (_ file: StaticString, _ line: UInt) -> Error,
        file: StaticString = #filePath,
        line: UInt = #line)
        throws
        -> Wrapped
    {
        return try unwrapOrThrow(
            error: error(
                file,
                line
            )
        )
    }
    
    public func unwrapOrThrow(
        message: (_ file: StaticString, _ line: UInt) -> String,
        file: StaticString = #filePath,
        line: UInt = #line)
        throws
        -> Wrapped
    {
        return try unwrapOrThrow(
            error: { file, line in
                UnwrappingError(message(file, line))
            },
            file: file,
            line: line
        )
    }
    
    public func unwrapOrThrow(
        message: @autoclosure () -> String)
        throws
        -> Wrapped
    {
        return try unwrapOrThrow(
            error: { UnwrappingError(message()) }()
        )
    }
    
    public func unwrapOrThrow(
        error: @autoclosure () -> Error)
        throws
        -> Wrapped
    {
        if let unwrapped = self {
            return unwrapped
        } else {
            throw error()
        }
    }
    
    public func unwrapOrThrow(
        file: StaticString = #filePath,
        line: UInt = #line)
        throws
        -> Wrapped
    {
        return try unwrapOrThrow(
            error: Self.defaultError,
            file: file,
            line: line
        )
    }

    public func unwrap(buildDefault: () throws -> Wrapped) rethrows -> Wrapped {
        guard let self else {
            return try buildDefault()
        }
        return self
    }

    public func unwrap(buildDefault: () async throws -> Wrapped) async rethrows -> Wrapped {
        guard let self else {
            return try await buildDefault()
        }
        return self
    }
    
    private static func defaultError(
        file: StaticString,
        line: UInt)
        -> Error
    {
        return UnwrappingError(
            defaultMessage(
                file: file,
                line: line
            )
        )
    }
    
    private static func defaultMessage(
        file: StaticString,
        line: UInt)
        -> String
    {
        return "Found nil when unwrapping optional at \(file):\(line)"
    }
}

private final class UnwrappingError: Error, CustomStringConvertible {
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var description: String {
        message
    }
}
