import Foundation

/// Defines package dependencies.
public struct PackageDependencies: Codable, Hashable {
    
    /// A list of modules which are provided by a system
    public let implicitSystemModules: [String]
    
    /// A list of modules which are defined by an external dependency
    public let external: [String: ExternalPackageLocation]
    
    public init(
        implicitSystemModules: [String],
        external: [String: ExternalPackageLocation]
    ) {
        self.implicitSystemModules = implicitSystemModules
        self.external = external
    }
    
}
