import CLTExtensions
import XCTest

class ArrayComparableTests: XCTestCase {
    func test() {
        XCTAssertFalse(
            [] < []
        )
        XCTAssert(
            [0] < [1]
        )
        XCTAssertFalse(
            [0] < [0]
        )
        XCTAssert(
            [0, 0] < [0, 1]
        )
        XCTAssertFalse(
            [0, 1] < [0, 0]
        )
        XCTAssertFalse(
            [0, 0] < [0, 0]
        )
        XCTAssert(
            [0] < [0, 0]
        )
        XCTAssertFalse(
            [1] < [0, 0]
        )
    }
}
