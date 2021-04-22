import Foundation
import XCTest

public extension XCTestCase {
    func failTest(
        _ message: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Never {
        withoutContinuingTestAfterFailure {
            XCTFail(message, file: file, line: line)
        }
        fatalError("Failing test with message: \(message)")
    }
}
