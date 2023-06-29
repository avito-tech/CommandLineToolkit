import Foundation
import XCTest

public extension XCTestCase {
    func XCTAssertEqualSorted<T: Equatable, Key: Comparable>(
        _ expression1: @autoclosure () throws -> [T],
        _ expression2: @autoclosure () throws -> [T],
        by keyPath: KeyPath<T, Key>,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) rethrows {
        let array1 = try expression1().sorted { lhs, rhs in
            try lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        }
        let array2 = try expression2().sorted { lhs, rhs in
            try lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
        }
        XCTAssertEqual(array1, array2, message(), file: file, line: line)
    }
}
