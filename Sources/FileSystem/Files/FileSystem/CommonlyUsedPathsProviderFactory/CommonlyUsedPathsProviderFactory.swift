import PathLib

public protocol CommonlyUsedPathsProviderFactory {
    var commonlyUsedPathsProvider: CommonlyUsedPathsProvider { get }
}

public extension CommonlyUsedPathsProviderFactory {
    
    // MARK: Applications
    
    /// Returns a path to Applications folder
    /// - Parameters:
    ///   - domain: Defines a location of `Applications` folder.
    ///   - create: Should the folder be created if it is missing.
    func applications(
        inDomain domain: SearchDomain,
        create: Bool
    ) throws -> AbsolutePath {
        try commonlyUsedPathsProvider.applications(inDomain: domain, create: create)
    }
    
    /// Returns a path to `/Applications` folder
    func localApplicationsFolder() throws -> AbsolutePath {
        try applications(inDomain: .local, create: true)
    }
    
    // MARK: Library
    
    /// Returns a path to Library folder
    /// - Parameters:
    ///   - domain: Defines a location of `Library` folder.
    ///   - create: Should the folder be created if it is missing.
    func library(
        inDomain domain: SearchDomain,
        create: Bool
    ) throws -> AbsolutePath {
        try commonlyUsedPathsProvider.library(inDomain: domain, create: create)
    }
    
    /// Returns a path to `~/Library` folder. Folder will created if it is missing.
    func userLibraryPath() throws -> AbsolutePath {
        try library(inDomain: .user, create: true)
    }
    
    // MARK: Caches
    
    /// Returns a path to Applications folder
    /// - Parameters:
    ///   - domain: Defines a location of `Library/Caches` folder.
    ///   - create: Should the folder be created if it is missing.
    func caches(
        inDomain domain: SearchDomain,
        create: Bool
    ) throws -> AbsolutePath {
        try commonlyUsedPathsProvider.caches(inDomain: domain, create: create)
    }
    
    /// Returns a path to `~/Library/Caches` folder. Folder will created if it is missing.
    func userCachesPath() throws -> AbsolutePath {
        try caches(inDomain: .user, create: true)
    }

    // MARK: CurrentWorkingDirectory
    
    var currentWorkingDirectory: AbsolutePath {
        commonlyUsedPathsProvider.currentWorkingDirectory
    }
}
