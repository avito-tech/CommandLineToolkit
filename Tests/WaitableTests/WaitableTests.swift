import Waitable
import XCTest

final class WaitableTests: XCTestCase {
    private lazy var queue = DispatchQueue(label: "queue")
    
    func test___wait_blocks() {
        let expectation = XCTestExpectation()
        expectation.isInverted = true
        
        let waitable = Waitable()
        
        // swiftlint:disable:next async
        queue.async {
            waitable.wait()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test___signal_unblocks() {
        let expectation = XCTestExpectation()
        
        let waitable = Waitable()
        
        // swiftlint:disable:next async
        queue.async {
            waitable.wait()
            expectation.fulfill()
        }
        
        let impactQueue = DispatchQueue(label: "impactQueue")
        
        // swiftlint:disable:next async
        impactQueue.async {
            waitable.signal()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
