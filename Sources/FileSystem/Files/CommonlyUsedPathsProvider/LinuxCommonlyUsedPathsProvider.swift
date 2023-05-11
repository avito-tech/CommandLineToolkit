import Foundation
import PathLib

public final class LinuxCommonlyUsedPathsProvider: CommonlyUsedPathsProvider {
    private let fileManager = FileManager()
    
    public init() {
    }
    
    public struct UnsupportedCommonPath: Error, CustomStringConvertible {
        public let locationName: String
        
        public var description: String {
            "Location \(locationName) is not supported on Linux"
        }
    }
    
    public func applications(inDomain domain: SearchDomain, create: Bool) throws -> AbsolutePath {
        throw UnsupportedCommonPath(locationName: "Applications")
    }
    
    public func caches(inDomain domain: SearchDomain, create: Bool) throws -> AbsolutePath {
        return AbsolutePath(NSTemporaryDirectory())
    }
    
    public func library(inDomain domain: SearchDomain, create: Bool) throws -> AbsolutePath {
        throw UnsupportedCommonPath(locationName: "Library")
    }
    
    public var currentWorkingDirectory: AbsolutePath {
        AbsolutePath(fileManager.currentDirectoryPath)
    }
}
