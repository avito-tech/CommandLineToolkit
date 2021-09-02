import PathLib
import Foundation

public final class CachingRepoRootProvider: RepoRootProvider {
    private let repoRootProvider: RepoRootProvider
    private var cachedValue: AbsolutePath?
    private let lock = NSLock()
    
    public init(repoRootProvider: RepoRootProvider) {
        self.repoRootProvider = repoRootProvider
    }
    
    public func repoRoot() throws -> AbsolutePath {
        lock.lock()
        defer { lock.unlock() }
    
        if let cachedValue = cachedValue {
            return cachedValue
        } else {
            let value = try repoRootProvider.repoRoot()
            self.cachedValue = value
            return value
        }
    }
}
