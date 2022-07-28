import Foundation
import XCTest

@discardableResult
public func assertNotNil<T>(
    file: StaticString = #filePath,
    line: UInt = #line,
    work: () throws -> T?
) rethrows -> T {
    guard let value = try work() else {
        failTest("Unexpected nil value", file: file, line: line)
    }
    return value
}

public func assertNil<T>(
    file: StaticString = #filePath,
    line: UInt = #line,
    work: () throws -> T?
) rethrows {
    guard let value = try work() else {
        return
    }
    failTest("Expected nil value, but got \(value)", file: file, line: line)
}
