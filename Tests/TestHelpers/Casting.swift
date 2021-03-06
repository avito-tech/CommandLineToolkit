import Foundation
import XCTest

@discardableResult
public func assertCast<T>(
    file: StaticString = #filePath,
    line: UInt = #line,
    provider: () throws -> Any
) rethrows -> T {
    let value = try provider()
    guard let castedValue = value as? T else {
        failTest("Can't cast value \(value) of type \(type(of: value)) to type \(T.self)", file: file, line: line)
    }
    return castedValue
}
