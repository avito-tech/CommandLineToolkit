import Foundation

public struct ContentMismatchError: Error, CustomStringConvertible {
    let packageSwiftFileUrl: URL
    
    public var description: String {
        "Contents of \(packageSwiftFileUrl.path) differs from expected. Please re-generate it and commit changes."
    }
}
