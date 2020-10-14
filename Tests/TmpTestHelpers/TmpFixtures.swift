import Foundation
import Tmp
import TestHelpers
import XCTest

public extension XCTestCase {
    func createTempFolder(
        deleteOnDealloc: Bool = true
    ) -> TemporaryFolder {
        assertDoesNotThrow {
            try TemporaryFolder(
                deleteOnDealloc: deleteOnDealloc
            )
        }
    }
}
