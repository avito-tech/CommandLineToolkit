import Foundation
import PathLib
import XCTest

public extension XCTestCase {
    func testDirectory() -> AbsolutePath {
        AbsolutePath(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(String(describing: type(of: self))))
    }
}
