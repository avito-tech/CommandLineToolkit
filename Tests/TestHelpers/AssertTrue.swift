import Foundation
import XCTest

public func assertTrue(
    message: @autoclosure () -> String = { "Unexpected result: got false instead of true" }(),
    file: StaticString = #filePath,
    line: UInt = #line,
    work: () throws -> Bool
) {
    let result = assertDoesNotThrow(file: file, line: line, work: work)
    XCTAssertTrue(result, message(), file: file, line: line)
}
