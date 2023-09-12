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
                guard isDirectory(url: targetUrl) else { continue }
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

    private static func isDirectory(url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        if FileManager().fileExists(atPath: url.path, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        }
        return false
    }
    
    private static func isDirectoryEmpty(url: URL) throws -> Bool {
        try isDirectory(url: url) &&
        FileManager().contentsOfDirectory(atPath: url.path).isEmpty
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
            settings: targetSettings,
            conditionalCompilationTargetRequirement: nil
        )
    }
    
    private static func importedModules(url: URL) throws -> Set<String> {
        let importsParser = try ImportsParser()
        
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
            
            importedModules.formUnion(
                importsParser.getImportedModuleNames(
                    sourceCode: try String(contentsOf: moduleFile)
                )
            )
        }
        
        return importedModules
    }
    
    private static func loadTargetSpecificSettings(url: URL) throws -> TargetSpecificSettings {
        let file = url.appendingPathComponent(TargetSpecificSettings.targetSpecificSettingsFile, isDirectory: false)
        guard FileManager().fileExists(atPath: file.path) else {
            return TargetSpecificSettings(linkerSettings: LinkerSettings(unsafeFlags: []))
        }
        return try JSONDecoder().decodeExplaining(TargetSpecificSettings.self, from: Data(contentsOf: file), context: file.path)
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
