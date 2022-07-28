import AtomicModels
import Foundation
import XCTest

public final class ValueOf<T> {
    public let value: AtomicValue<T?>
    public var expectation: XCTestExpectation
    
    public init(
        _ value: T? = nil,
        expectation: XCTestExpectation = XCTestExpectation(description: "Set value of \(type(of: T.self)) type")
    ) {
        self.value = AtomicValue(value)
        self.expectation = expectation
    }
    
    public struct ValueIsNilError<T>: Error, CustomStringConvertible {
        public var description: String {
            "Value of type \(type(of: T.self)) was not yet set"
        }
    }
    
    public func get() throws -> T {
        if let value = value.currentValue() {
            return value
        }
        throw ValueIsNilError<T>()
    }
    
    public func set(_ newValue: T) {
        self.value.set(newValue)
        
        expectation.fulfill()
    }
    
    public func getWhenAvailable(
        testCase: XCTestCase,
        timeout: TimeInterval = 10
    ) throws -> T {
        testCase.wait(for: expectation, timeout: timeout)
        return try get()
    }
    
    public func callAsFunction() throws -> T {
        return try get()
    }
}
