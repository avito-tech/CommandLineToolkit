import Foundation

public extension PackageTarget {
    
    /// Automatically discovers all targets for a given package location (path).
    static func discoverTargets(packageLocation: URL) throws -> [PackageTarget] {
        var packageTargets = [PackageTarget]()
        packageTargets.append(
            contentsOf: try generate(at: packageLocation.appendingPathComponent("Sources", isDirectory: true), isTestTarget: false)
        )
        packageTargets.append(
            contentsOf: try generate(at: packageLocation.appendingPathComponent("Tests", isDirectory: true), isTestTarget: true)
        )
        return packageTargets
    }

    private static func generate(at url: URL, isTestTarget: Bool) throws -> [PackageTarget] {
        // `@testable import ModuleName // from package-name`, with optional `@testable ` and `// from package-name` parts
        let importStatementExpression = try NSRegularExpression(
            pattern: "^(@testable )?import (\\S+)$",
            options: [.anchorsMatchLines]
        )
        
        guard let enumerator = FileManager().enumerator(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
        ) else {
            fatalError("Failed to create file enumerator at '\(url.path)'")
        }
        
        var result = [PackageTarget]()

        while let moduleFolderUrl = enumerator.nextObject() as? URL {
            let moduleEnumerator = FileManager().enumerator(
                at: moduleFolderUrl,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            let moduleName = moduleFolderUrl.lastPathComponent
            log("Analyzing \(moduleName)")
            
            var importedDependencies = Set<String>()
            
            while let moduleFile = moduleEnumerator?.nextObject() as? URL {
                if ["md"].contains(moduleFile.pathExtension) {
                    continue
                }
                log("    Analyzing \(moduleFile.lastPathComponent)")
                guard try moduleFile.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else {
                    log("    Skipping \(moduleFile.lastPathComponent): is not regular file")
                    continue
                }
                let fileContents = try String(contentsOf: moduleFile)
                    .split(separator: "\n")
                    .filter { !$0.starts(with: "//") }
                for line in fileContents {
                    let matches = importStatementExpression.matches(in: String(line), options: [], range: NSRange(location: 0, length: line.count))
                    guard matches.count == 1 else {
                        continue
                    }
                    
                    let importedModuleName = (line as NSString).substring(with: matches[0].range(at: 2))
                    importedDependencies.insert(importedModuleName)
                }
            }
            
            let path = moduleFolderUrl.path.dropFirst(moduleFolderUrl.deletingLastPathComponent().deletingLastPathComponent().path.count + 1)
            
            let isTestHelper = moduleFolderUrl.path.hasSuffix("TestHelpers")
            
            result.append(
                PackageTarget(
                    name: moduleName,
                    dependencies: importedDependencies,
                    path: String(path),
                    isTest: isTestTarget && !isTestHelper
                )
            )
        }
        
        return result
    }

}
