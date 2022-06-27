import Foundation
import ProcessController
import TestHelpers
import XCTest

final class EnvironmentSecureValueTests: XCTestCase {
    func test() {
        let env: Environment = [
            "env1": "12345".secured,
            "env2": "54321",
        ]
        
        assertFalse {
            env.description.contains("12345")
        }
        
        assertTrue {
            env.description.contains("54321")
        }
    }
}
