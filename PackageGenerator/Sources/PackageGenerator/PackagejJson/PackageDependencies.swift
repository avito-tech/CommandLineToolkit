import Foundation

/// Defines package dependencies.
public struct PackageDependencies: Codable, Hashable {
    
    /// A list of modules which are provided by a system
    public let implicitSystemModules: [String]
    
    /// A list of modules which are defined by an external dependency
    public let external: [String: ExternalPackageLocation]
    
    /// A path to mirror file which should be used to set up SPM mirroring configuration. If not set, "package_generator_mirrors.json" will be searched in package and all parrent directories.
    public let mirrorsFilePath: String?
    
    public init(
        implicitSystemModules: [String],
        external: [String: ExternalPackageLocation],
        mirrorsFilePath: String?
    ) {
        self.implicitSystemModules = implicitSystemModules
        self.external = external
        self.mirrorsFilePath = mirrorsFilePath
    }
    
    public static let defaultMirrorsFileName = "package_generator_mirrors.json"
}
