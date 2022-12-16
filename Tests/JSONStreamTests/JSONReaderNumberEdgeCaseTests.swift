import Foundation
import JSONStream
import XCTest

class JSONReaderNumberEdgeCaseTests: XCTestCase {
    let eventStream = FakeEventStream()
    
    func testNumberJustMinusShouldFail() throws {
        let jsonStream = FakeJSONStream(string: "[-]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNegativeNumberWithoutIntPartShouldFail() throws {
        let jsonStream = FakeJSONStream(string: "[-.123]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNegativeNumberWithoutFractionalPartShouldFail() throws {
        let jsonStream = FakeJSONStream(string: "[-2.]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNumberWithLeadingZeroFails() throws {
        let jsonStream = FakeJSONStream(string: "[01]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNegativeNumberWithLeadingZeroFails() throws {
        let jsonStream = FakeJSONStream(string: "[-01]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNumberWithoutFractionalPartWithExponentialPartFails() throws {
        let jsonStream = FakeJSONStream(string: "[0.e1]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNumberWithIntFractionalPositiveExponentialPartsSucceedes() throws {
        let jsonStream = FakeJSONStream(string: "[0.1e+1]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        try reader.start()
        XCTAssertEqual(eventStream.allArrays[0], [1])
    }
    
    func testNegativeNumberWithIntFractionalNegativeExponentialPartsSucceedes() throws {
        let jsonStream = FakeJSONStream(string: "[-0.1e-1]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        try reader.start()
        XCTAssertEqual(eventStream.allArrays[0], [-0.01])
    }
    
    func testNegativeNumberWithWrongMinusMinusxponentialPartFails() throws {
        try XCTSkipIf(shouldSkipDueToNumberFormatDifferences())
        
        let jsonStream = FakeJSONStream(string: "[-0.1e--1]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNegativeNumberWithWrongPlusPlusExponentialPartFails() throws {
        try XCTSkipIf(shouldSkipDueToNumberFormatDifferences())
        
        let jsonStream = FakeJSONStream(string: "[-0.1e++1]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNegativeNumberWithWrongPlusMinusExponentialPartFails() throws {
        try XCTSkipIf(shouldSkipDueToNumberFormatDifferences())

        let jsonStream = FakeJSONStream(string: "[0.1e+-1]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNumberWithEmptyExponentialPartFails() throws {
        let jsonStream = FakeJSONStream(string: "[0.3e]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testNumberWithEmptyExponentialPlusPartFails() throws {
        try XCTSkipIf(shouldSkipDueToNumberFormatDifferences())
        
        let jsonStream = FakeJSONStream(string: "[0.3e+]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    func testPlusNumberFails() throws {
        let jsonStream = FakeJSONStream(string: "[+1]")
        let reader = JSONReader(inputStream: jsonStream, eventStream: eventStream)
        XCTAssertThrowsError(try reader.start())
    }
    
    private func shouldSkipDueToNumberFormatDifferences() -> Bool {
        // https://github.com/apple/swift-corelibs-foundation/issues/4680
#if os(macOS)
        return false
#elseif os(Linux)
        return true
#else
        #error("Unsupported OS")
#endif
    }
}
