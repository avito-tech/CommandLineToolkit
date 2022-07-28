import Foundation
import XCTest

public func failTest(
    _ message: String,
    file: StaticString = #filePath,
    line: UInt = #line
) -> Never {
    XCTFail(message, file: file, line: line)
#if os(macOS)    
    NSException(name: NSExceptionName(rawValue: message), reason: nil, userInfo: nil).raise()
#endif
    fatalError(message, file: (file), line: line)
}
