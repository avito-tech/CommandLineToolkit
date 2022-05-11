import Foundation

public protocol FilePathResolver {
    func absoluteUrl(
        from path: FilePath,
        generatablePackageLocation: URL
    ) throws -> URL
}

public final class FilePathResolverImpl: FilePathResolver {
    private let repoRootProvider: RepoRootProvider
    
    public init(repoRootProvider: RepoRootProvider) {
        self.repoRootProvider = repoRootProvider
    }
    
    public func absoluteUrl(
        from path: FilePath,
        generatablePackageLocation: URL
    ) throws -> URL {
        switch path.root {
        case .currentPackage:
            return generatablePackageLocation.appendingPathComponent(path.relativePath, isDirectory: false)
        case .repoRoot:
            let repoRoot = try repoRootProvider.repoRoot(generatablePackageLocation: generatablePackageLocation)
            return repoRoot.appendingPathComponent(path.relativePath)
        }
    }
}
