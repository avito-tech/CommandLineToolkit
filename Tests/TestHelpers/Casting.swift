import CLTExtensions
import Foundation
import XCTest

@discardableResult
public func assertCast<T>(
    file: StaticString = #filePath,
    line: UInt = #line,
    provider: () throws -> Any
) rethrows -> T {
    let value = try provider()
    
    return assertDoesNotThrow {
        try cast(value: value, to: T.self)
    }
}
