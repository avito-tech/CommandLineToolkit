import Foundation

public extension PackageTarget {
    
    /// Automatically discovers all targets for a given package location (path).
    static func discoverTargets(packageLocation: URL) throws -> [PackageTarget] {
        let packageTargets: [PackageTarget]
        let targetsLocation = packageLocation.appendingPathComponent("Targets", isDirectory: true)
        if FileManager().fileExists(atPath: targetsLocation.path) {
            packageTargets = try targetsWithAdjacentSourcesAndTests(
                targetsLocation: targetsLocation,
                packageLocation: packageLocation
            )
        } else {
            packageTargets = try targetsWithSeparateSourcesAndTests(packageLocation: packageLocation)
        }
        return packageTargets
    }
    
    private static func targetsWithAdjacentSourcesAndTests(
        targetsLocation: URL,
        packageLocation: URL
    ) throws -> [PackageTarget] {
        var packageTargets = [PackageTarget]()
        let enumerator = subdirectriesEnumerator(url: targetsLocation)
        
        while let targetContainerUrl = enumerator.nextObject() as? URL {
            let targetsEnumerator = subdirectriesEnumerator(url: targetContainerUrl)
            while let targetUrl = targetsEnumerator.nextObject() as? URL {
                guard try !isDirectoryEmpty(url: targetUrl) else {
                    log("Folder at \(targetUrl.path) is empty, won't create module for it")
                    continue
                }
                
                var targetName = targetContainerUrl.lastPathComponent
                if targetUrl.lastPathComponent != "Sources" {
                    targetName = "\(targetName)\(targetUrl.lastPathComponent)"
                }
                let isTestTarget = targetUrl.lastPathComponent == "Tests"
                
                log("Found \(isTestTarget ? "test " : "")target \(targetName) at \(targetUrl.path)")
                try packageTargets.append(
                    generateTarget(
                        moduleName: targetName,
                        url: targetUrl,
                        packageLocation: packageLocation,
                        isTest: isTestTarget
                    )
                )
            }
        }
        return packageTargets
    }
    
    private static func isDirectoryPresent(url: URL, perform: () throws -> ()) rethrows {
        if FileManager().fileExists(atPath: url.path) {
            try perform()
        }
    }
    
    private static func isDirectoryEmpty(url: URL) throws -> Bool {
        try FileManager().contentsOfDirectory(atPath: url.path).isEmpty
    }
    
    private static func targetsWithSeparateSourcesAndTests(packageLocation: URL) throws -> [PackageTarget] {
        var packageTargets = [PackageTarget]()
        packageTargets.append(
            contentsOf: try generateTargetsWithSeparateSourcesAndTests(
                at: packageLocation.appendingPathComponent("Sources", isDirectory: true),
                packageLocation: packageLocation,
                isTestTarget: false
            )
        )
        packageTargets.append(
            contentsOf: try generateTargetsWithSeparateSourcesAndTests(
                at: packageLocation.appendingPathComponent("Tests", isDirectory: true),
                packageLocation: packageLocation,
                isTestTarget: true
            )
        )
        return packageTargets
    }

    private static func generateTargetsWithSeparateSourcesAndTests(
        at url: URL,
        packageLocation: URL,
        isTestTarget: Bool
    ) throws -> [PackageTarget] {
        let enumerator = subdirectriesEnumerator(url: url)
        var result = [PackageTarget]()

        while let moduleFolderUrl = enumerator.nextObject() as? URL {
            let isTestHelper = moduleFolderUrl.path.hasSuffix("TestHelpers")
            result.append(
                try generateTarget(
                    moduleName: moduleFolderUrl.lastPathComponent,
                    url: moduleFolderUrl,
                    packageLocation: packageLocation,
                    isTest: isTestTarget && !isTestHelper
                )
            )
        }
        
        return result
    }
    
    private static func generateTarget(
        moduleName: String,
        url: URL,
        packageLocation: URL,
        isTest: Bool
    ) throws -> PackageTarget {
        log("Analyzing \(moduleName)")
        
        let targetSettings = try loadTargetSpecificSettings(url: url)
        
        let path = url.path.dropFirst(
            packageLocation.standardized.path.count + 1
        )
        
        return try PackageTarget(
            name: moduleName,
            dependencies: importedModules(url: url),
            path: String(path),
            isTest: isTest,
            settings: targetSettings
        )
    }
    
    private static func importedModules(url: URL) throws -> Set<String> {
        // `@testable import ModuleName // from package-name`, with optional `@testable ` and `// from package-name` parts
        let importStatementExpression = try NSRegularExpression(
            pattern: "^(@testable )?import (\\S+)$",
            options: [.anchorsMatchLines]
        )
        
        let moduleEnumerator = FileManager().enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        var importedModules = Set<String>()
        
        while let moduleFile = moduleEnumerator?.nextObject() as? URL {
            if moduleFile.pathExtension != "swift" {
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
                importedModules.insert(importedModuleName)
            }
        }
        
        return importedModules
    }
    
    private static func loadTargetSpecificSettings(url: URL) throws -> TargetSpecificSettings {
        let file = url.appendingPathComponent("target.json", isDirectory: false)
        guard FileManager().fileExists(atPath: file.path) else {
            return TargetSpecificSettings(linkerSettings: LinkerSettings(unsafeFlags: []))
        }
        return try JSONDecoder().decode(TargetSpecificSettings.self, from: Data(contentsOf: file))
    }
    
    private static func subdirectriesEnumerator(url: URL) -> FileManager.DirectoryEnumerator {
        guard let enumerator = FileManager().enumerator(
            at: url,
            includingPropertiesForKeys: nil,
            options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]
        ) else {
            fatalError("Failed to create file enumerator at '\(url.path)'")
        }
        return enumerator
    }
}
