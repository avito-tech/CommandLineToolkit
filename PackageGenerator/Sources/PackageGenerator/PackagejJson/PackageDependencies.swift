import Foundation

/// Defines package dependencies.
public struct PackageDependencies: Codable, Hashable {
    
    /// A list of modules which are provided by a system
    public let implicitSystemModules: [String]
    
    /// A list of modules which are defined by an external dependency
    public let external: [String: ExternalPackageLocation]
    
    /// A path to mirror file which should be used to set up SPM mirroring configuration.
    public let mirrorFilePath: FilePath?
    
    public init(
        implicitSystemModules: [String],
        external: [String: ExternalPackageLocation],
        mirrorFilePath: FilePath? = nil
    ) {
        self.implicitSystemModules = implicitSystemModules
        self.external = external
        self.mirrorFilePath = mirrorFilePath
    }
}
