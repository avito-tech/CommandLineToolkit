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
    
    let generator = SwiftPackageGenerator(directoryContainingPackageSwiftFile: packageLocation)
    let generatedContents = try generator.generateContents()
    
    // Note that Package.swift can be under `.gitignore`. For this case the check is not valid and makes no sense.
    // Don't pass `VERIFY_PACKAGE_CONTENTS_ARE_UNCHANGED` if Package.swift is ignored.
    if ProcessInfo.processInfo.environment["SHOULD_VERIFY_THAT_PACKAGE_CONTENTS_ARE_UNCHANGED"] == "true" {
        try generator.assertCurrentContentsEquals(generatedContents: generatedContents)
    } else {
        try generator.store(generatedContents: generatedContents)
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
