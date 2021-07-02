import Foundation
import XCTest

public func failTest(
    _ message: String,
    file: StaticString = #filePath,
    line: UInt = #line
) -> Never {
    XCTFail(message, file: file, line: line)
    fatalError("Failing test with message: \(message)")
}
