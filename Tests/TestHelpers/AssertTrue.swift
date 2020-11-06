import Foundation
import XCTest

public extension XCTestCase {
    func assertTrue(
        message: () -> String = { "Unexpected result: got false instead of true" },
        file: StaticString = #file,
        line: UInt = #line,
        work: () throws -> Bool
    ) {
        let result = assertDoesNotThrow { try work() }
        XCTAssertTrue(result, message(), file: file, line: line)
    }
}