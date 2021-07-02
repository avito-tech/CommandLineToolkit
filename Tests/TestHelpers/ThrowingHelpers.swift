import Foundation
import XCTest

@discardableResult
public func assertDoesNotThrow<T>(
    message: (Error) -> String = { "Unexpected error thrown: \($0)" },
    file: StaticString = #filePath,
    line: UInt = #line,
    work: () throws -> T
) -> T {
    do {
        return try work()
    } catch {
        failTest(message(error), file: file, line: line)
    }
}

public func assertThrows<T>(
    file: StaticString = #filePath,
    line: UInt = #line,
    work: () throws -> (T)
) {
    do {
        _ = try work()
        failTest("Expected to throw an error, but no error has been thrown", file: file, line: line)
    } catch {
        return
    }
}
