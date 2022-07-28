import Foundation
import XCTest

extension XCTestCase {
    public func wait(for expectation: XCTestExpectation, timeout: TimeInterval = 10) {
        wait(for: [expectation], timeout: timeout)
    }
}
