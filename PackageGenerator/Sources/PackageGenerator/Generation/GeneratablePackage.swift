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
    
    /// This method returns a path to package's `.build/checkouts/` folder.
    /// It takes in account that this folder is shared for all remote packages.
    public var buildCheckoutUrl: URL {
        var pathToRootPackageWhichContainsBuildCheckout = location
        
        while pathToRootPackageWhichContainsBuildCheckout.pathComponents.contains(".build") {
            pathToRootPackageWhichContainsBuildCheckout.deleteLastPathComponent()
        }
        
        return pathToRootPackageWhichContainsBuildCheckout.appendingPathComponent(".build/checkouts/", isDirectory: true)
    }
    
    public func checkout(forPackage externalPackageName: String) -> URL {
        buildCheckoutUrl.appendingPathComponent(externalPackageName, isDirectory: true)
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
    
    /// SPM mirror configuration file for Xcoder 13.3 and later.
    public var mirrorsFile_xcode13_3: URL {
        location.appendingPathComponent(".swiftpm/configuration/mirrors.json", isDirectory: false)
    }
    
    /// SPM mirror configuration file for Xcoder 13.2 and earlier.
    public var mirrorsFile_pre_xcode13_3: URL {
        location.appendingPathComponent(".swiftpm/config", isDirectory: false)
    }

    private static func packageJsonUrl(for location: URL) -> URL {
        location.appendingPathComponent("package.json", isDirectory: false)
    }
}
