import Foundation
import XCTest

public func failTest(
    _ message: String,
    file: StaticString = #filePath,
    line: UInt = #line
) -> Never {
    XCTFail(message, file: file, line: line)
#if os(macOS) || os(iOS) || os(tvOS)    
    NSException(name: NSExceptionName(rawValue: message), reason: nil, userInfo: nil).raise()
#endif
    fatalError("Failing test with message: \(message)")
}
