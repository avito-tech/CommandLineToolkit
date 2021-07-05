import Foundation
import XCTest

public func assertFalse(
    message: @autoclosure () -> String = { "Unexpected result: got true instead of false" }(),
    file: StaticString = #filePath,
    line: UInt = #line,
    work: () throws -> Bool
) {
    let result = assertDoesNotThrow(file: file, line: line, work: work)
    XCTAssertFalse(result, message(), file: file, line: line)
}
