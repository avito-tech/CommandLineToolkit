import CLTCollections
import Foundation
import TestHelpers
import XCTest

final class Array_UniquifyTests: XCTestCase {
    struct S: Hashable, Comparable {
        static func < (lhs: Array_UniquifyTests.S, rhs: Array_UniquifyTests.S) -> Bool {
            if lhs.name != rhs.name {
                return lhs.name < rhs.name
            }
            return lhs.random.uuidString < rhs.random.uuidString
        }
        
        let name: String
        let random = UUID()
    }
    
    lazy var array = [
        S(name: "One"),
        S(name: "One"),
        S(name: "Two"),
    ]
    
    func test___uniquify() {
        assert {
            array.uniquified().sorted()
        } equals: {
            array.sorted()
        }
    }
    
    func test___uniquify_by_keypath() {
        assert {
            array.uniquified(by: \.name)
        } equals: {
            [
                array[0],
                array[2],
            ]
        }
    }
}
