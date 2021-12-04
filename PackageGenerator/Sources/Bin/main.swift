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
    
    let environment = ProcessInfo.processInfo.environment
    
    // Note that Package.swift can be under `.gitignore`. For this case the check is not valid and makes no sense.
    // Don't pass `VERIFY_PACKAGE_CONTENTS_ARE_UNCHANGED` if Package.swift is ignored.
    // Don't forget that SPM requires Package.swift to be present in a repo.
    let shouldVerifyThatPackageContentsAreUnchanged = environment["SHOULD_VERIFY_THAT_PACKAGE_CONTENTS_ARE_UNCHANGED"] == "true"
    
    // If for any reason it is impossible to write out generated Package.swift, error will be logger in any case.
    // This env enables failing the process entirely.
    // In some cases it is impossible to store Package.swift, e.g. if it is inside remote repo checkout - in this case files are read-only.
    // That's why this behaviour is opt-in instead of opt-out.
    let failOnPackageWriteFailure = environment["FAIL_ON_PACKAGE_WRITE_FAILURE"] == "true"
    
    let generator = SwiftPackageGenerator(
        directoryContainingPackageSwiftFile: packageLocation,
        failOnStoreError: failOnPackageWriteFailure
    )
    let generatedContents = try generator.generateContents()
    
    if shouldVerifyThatPackageContentsAreUnchanged {
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
