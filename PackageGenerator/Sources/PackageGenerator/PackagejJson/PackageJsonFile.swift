import Foundation

/// Describes contents of `Package.swift` fiile
public struct PackageJsonFile: Codable, Hashable {
    
    /// Swift tooling version, e.g. for "5.2" this statement will be generated: `// swift-tools-version:5.2`
    public let swiftToolsVersion: String
    
    /// Name of the entire package
    public let name: String
    
    /// All platforms supported by the package
    public let platforms: [PackagePlatform]
    
    /// All products exported by the package
    public let products: PackageProducts
    
    /// All package dependencies, both local and remote.
    public let dependencies: PackageDependencies
    
    /// All package targets
    public let targets: PackageTargets
    
    public init(swiftToolsVersion: String, name: String, platforms: [PackagePlatform], products: PackageProducts, dependencies: PackageDependencies, targets: PackageTargets) {
        self.swiftToolsVersion = swiftToolsVersion
        self.name = name
        self.platforms = platforms
        self.products = products
        self.dependencies = dependencies
        self.targets = targets
    }
}
