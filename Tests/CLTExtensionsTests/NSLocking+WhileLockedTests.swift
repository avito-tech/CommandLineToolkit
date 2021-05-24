import CLTExtensions
import XCTest

final class NSLockingWhileLockedTests: XCTestCase {
    let lock = NSLock()
    
    func test___returns_value() {
        let value: Bool = lock.whileLocked { true }
        
        XCTAssertTrue(value)
    }
    
    func test___locks() {
        lock.whileLocked {
            XCTAssertFalse(lock.try())
        }
    }
}
