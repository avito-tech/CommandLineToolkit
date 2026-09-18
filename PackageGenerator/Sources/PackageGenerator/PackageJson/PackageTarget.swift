import Foundation

/// Package target
public struct PackageTarget: Codable, Hashable {
    
    /// Name of the target
    public let name: String
    
    /// Target dependencies (other target names)
    public let dependencies: Set<String>
    
    /// Path to source files
    public let path: String
    
    /// Is this target is test target
    public let isTest: Bool
    
    /// Various target specific settings
    public let settings: TargetSpecificSettings
    
    /// `#if` requirements for this target to be included into package
    public let conditionalCompilationTargetRequirement: ConditionalCompilationTargetRequirement?
    
    public init(
        name: String,
        dependencies: Set<String>,
        path: String,
        isTest: Bool,
        settings: TargetSpecificSettings,
        conditionalCompilationTargetRequirement: ConditionalCompilationTargetRequirement?
    ) {
        self.name = name
        self.dependencies = dependencies
        self.path = path
        self.isTest = isTest
        self.settings = settings
        self.conditionalCompilationTargetRequirement = conditionalCompilationTargetRequirement
    }
}
