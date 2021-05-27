import String
import Foundation
import XCTest

final class StringUTF8Tests: XCTestCase {
    func test___initializing___with_utf8_bytes_sequence___is_successful() throws {
        try XCTAssertEqual(
            String(utf8Data: Data([0xf0, 0x9f, 0x98, 0x80])),
            "😀"
        )
    }
    
    func test___initializing___bogus_bytes_sequence___throws_error() throws {
        var error: Error?
        try XCTAssertThrowsError(
            String(utf8Data: Data([0x01, 0x9f, 0x98, 0x80]))
        ) { error = $0 }
        XCTAssertEqual(
            error.map { String(describing: $0) },
            "Bytes AZ+YgA== are not utf8"
        )
    }
}
