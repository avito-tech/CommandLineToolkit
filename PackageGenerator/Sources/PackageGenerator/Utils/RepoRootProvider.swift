import Foundation

public protocol RepoRootProvider {
    func repoRoot(generatablePackageLocation: URL) throws -> URL
}

public final class RepoRootProviderImpl: RepoRootProvider {
    public init() {}
    
    public struct RepoRootNotFound: Error, CustomStringConvertible {
        public let generatablePackageLocation: URL
        public var description: String { "Repo root can't be found for \(generatablePackageLocation.path)" }
    }
    
    public func repoRoot(generatablePackageLocation: URL) throws -> URL {
        var url = generatablePackageLocation
        while !url.pathComponents.isEmpty {
            let gitUrl = url.appendingPathComponent(".git")
            
            if (try? gitUrl.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                return url
            }
            
            url = url.deletingLastPathComponent()
        }
        
        throw RepoRootNotFound(generatablePackageLocation: generatablePackageLocation)
    }
}
