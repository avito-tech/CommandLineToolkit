import Foundation

public class Package {
    public let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public var packageSwiftUrl: URL {
        url.appendingPathComponent("Package.swift", isDirectory: false)
    }
    
    public var packageJsonUrl: URL {
        url.appendingPathComponent("package.json", isDirectory: false)
    }
    
    public func loadSwiftPackage() throws -> SwiftPackage {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(
            SwiftPackage.self,
            from: try Data(contentsOf: packageJsonUrl)
        )
    }
}
