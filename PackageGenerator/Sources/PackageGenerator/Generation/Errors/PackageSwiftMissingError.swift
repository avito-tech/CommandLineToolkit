import Foundation

public struct PackageSwiftMissingError: Error, CustomStringConvertible {
    let packageSwiftFileUrl: URL
    
    public var description: String {
        """
        File doesn't exist at path \(packageSwiftFileUrl.path), but is expected to be present. Please re-generate package and commit changes.
        """
    }
}
