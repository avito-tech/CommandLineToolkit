import Foundation

/// Represents a folder with package.json file from which Package.swift is generated
public struct GeneratablePackage: Hashable {
    public let location: URL
    public let packageJsonFile: PackageJsonFile
    
    public init(
        location: URL,
        packageJsonFile: PackageJsonFile
    ) {
        self.location = location
        self.packageJsonFile = packageJsonFile
    }
    
    public init(location: URL) throws {
        self.init(
            location: location,
            packageJsonFile: try JSONDecoder().decode(
                PackageJsonFile.self,
                from: try Data(contentsOf: Self.packageJsonUrl(for: location))
            )
        )
    }
    
    public var packageSwiftUrl: URL {
        location.appendingPathComponent("Package.swift", isDirectory: false)
    }
    
    public var packageJsonUrl: URL {
        Self.packageJsonUrl(for: location)
    }
    
    /// An executable file which should be executed before `Package.swift` file will be generated.
    public var preflightExecutableUrl: URL {
        location.appendingPathComponent("package_preflight", isDirectory: false)
    }
    
    /// An executable file which should be executed after `Package.swift` file will be generated.
    public var postflightExecutableUrl: URL {
        location.appendingPathComponent("package_postflight", isDirectory: false)
    }

    private static func packageJsonUrl(for location: URL) -> URL {
        location.appendingPathComponent("package.json", isDirectory: false)
    }
}
