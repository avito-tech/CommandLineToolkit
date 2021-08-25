import Foundation
import XCTest

public func failTest(
    _ message: String,
    file: StaticString = #filePath,
    line: UInt = #line
) -> Never {
    XCTFail(message, file: file, line: line)
    NSException(name: NSExceptionName(rawValue: message), reason: nil, userInfo: nil).raise()
    fatalError("Failing test with message: \(message)")
}
