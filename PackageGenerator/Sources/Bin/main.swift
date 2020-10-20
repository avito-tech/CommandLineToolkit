import Foundation
import PackageGenerator

func main() throws {
    let arguments = ProcessInfo.processInfo.arguments
    guard arguments.count == 2 else {
        fatalError("Usage: \((arguments[0] as NSString).lastPathComponent) <path to package folder>")
    }
    let packageLocation = URL(fileURLWithPath: arguments[1])
    guard FileManager().isDirectory(packageLocation) else {
        fatalError("File at \(packageLocation.path) does not exists or not writable")
    }
    
    let package = Package(url: packageLocation)
    
    let packageSwiftContents = try StatementGenerator().generatePackageSwiftCode(
        swiftPackage: try package.loadSwiftPackage(),
        location: packageLocation
    ).joined(separator: "\n")
        
    if ProcessInfo.processInfo.environment["ON_CI"] == "true" {
        let currentContents = try Data(contentsOf: package.packageSwiftUrl)
        if currentContents != packageSwiftContents.data(using: .utf8) {
            fatalError("Contents of \(package.packageSwiftUrl.path) differs from expected. Please re-generate it and commit changes.")
        }
    } else {
        try packageSwiftContents
            .data(using: .utf8)?
            .write(to: package.packageSwiftUrl)
    }
}

extension FileManager {
    func isDirectory(_ url: URL) -> Bool {
        var result: ObjCBool = false
        guard fileExists(atPath: url.path, isDirectory: &result) else {
            return false
        }
        return result.boolValue
    }
}

try main()
