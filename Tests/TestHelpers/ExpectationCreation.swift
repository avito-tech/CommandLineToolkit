import Foundation
import XCTest

public func testExpectation(_ description: String = "") -> XCTestExpectation {
    return XCTestExpectation(description: description)
}

public func invertedTestExpectation(_ description: String = "") -> XCTestExpectation {
    let expectation = testExpectation(description)
    expectation.isInverted = true
    return expectation
}
