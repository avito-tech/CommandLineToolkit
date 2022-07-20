import Foundation

public struct ContentMismatchError: Error, CustomStringConvertible {
    let packageSwiftFileUrl: URL
    let currentContents: String
    let generatedContents: String
    
    public var description: String {
        """
        Contents of \(packageSwiftFileUrl.path) differs from expected. Please re-generate it and commit changes.

        Generated contents:
        \(generatedContents)

        Current contents:
        \(currentContents)
        """
    }
}
