import Foundation
import PathLib

public enum SearchDomain {
    /// User's home directory --- place to install user's personal items (`~`)
    case user
    
#if os(macOS)
    /// Local to the current machine --- place to install items available to everyone on this machine (`/Library`)
    case local
    
    /// Publically available location in the local area network --- place to install items available on the network (`/Network`)
    case network
    
    /// Provided by Apple, unmodifiable (/System)
    case system
#endif
}

public protocol CommonlyUsedPathsProvider {
    func applications(inDomain: SearchDomain, create: Bool) throws -> AbsolutePath
    func caches(inDomain: SearchDomain, create: Bool) throws -> AbsolutePath
    func library(inDomain: SearchDomain, create: Bool) throws -> AbsolutePath
    var currentWorkingDirectory: AbsolutePath { get }
}
