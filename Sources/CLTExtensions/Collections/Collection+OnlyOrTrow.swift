extension Collection {
    public func onlyOneOrThrow(
        message: @autoclosure () -> OnlyOrThrowMessageProvider = defaultMessageProvider,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Iterator.Element {
        try onlyOrThrow(
            message: message(),
            file: file,
            line: line
        )
    }
    
    public func onlyOrThrow(
        message: @autoclosure () -> OnlyOrThrowMessageProvider = defaultMessageProvider,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Iterator.Element {
        try onlyOrThrow(
            count: 1,
            getter: at(0),
            message: message,
            file: file,
            line: line
        )
    }
    
    public func onlyOrThrow(
        message: @autoclosure () -> OnlyOrThrowMessageProvider = defaultMessageProvider,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (Iterator.Element, Iterator.Element) {
        try onlyOrThrow(
            count: 2,
            getter: (at(0), at(1)),
            message: message,
            file: file,
            line: line
        )
    }
    
    private func at(_ index: Int) -> Iterator.Element {
        return self[self.index(startIndex, offsetBy: index)]
    }
    
    private func onlyOrThrow<T>(
        count: Int,
        getter: @autoclosure () -> T,
        message: () -> OnlyOrThrowMessageProvider,
        file: StaticString,
        line: UInt
    ) throws -> T {
        if self.count != count {
            throw message().provideMessage(
                expectedCount: count,
                actualCount: self.count,
                file: file,
                line: line
            )
        } else {
            return getter()
        }
    }
    
    public static var defaultMessageProvider: OnlyOrThrowMessageProvider {
        OnlyOrThrowMessageProvider { expectedCount, actualCount, file, line in
            """
            Expected exactly \(expectedCount) elements in the collection, \
            actual count: \(actualCount), \
            location: \(file):\(line)
            """
        }
    }
}

public final class OnlyOrThrowMessageProvider: ExpressibleByStringInterpolation {
    public typealias StringLiteralType = String
    
    private let provideMessageClosure: (Int, Int, StaticString, UInt) -> String
    
    public init(stringLiteral value: String) {
        provideMessageClosure = { _, _, _, _ in
            value
        }
    }
    
    public init(closure: @escaping (Int, Int, StaticString, UInt) -> String) {
        provideMessageClosure = closure
    }
    
    public func provideMessage(
        expectedCount: Int,
        actualCount: Int,
        file: StaticString,
        line: UInt
    ) -> String {
        provideMessageClosure(
            expectedCount,
            actualCount,
            file,
            line
        )
    }
}
