import Foundation

public struct GeneratedPackageContents: Hashable {
    public let contents: String
    public let package: GeneratablePackage
}

public final class StatementGenerator {
    private var packageTargetCache = [URL: [PackageTarget]]()
    
    public init() {}
    
    public func generatePackageSwiftCode(
        generatablePackage: GeneratablePackage
    ) throws -> Set<GeneratedPackageContents> {
        try willGenerate(generatablePackage: generatablePackage)
        
        var importedDependencyCache = [String: ImportedDependency]()
        var output = [String]()
        
        var anotherPackagesReferencedByPackageBeingGenerated = Set<GeneratablePackage>()
        
        let packageTargets = try obtainPackageTargets(generatablePackage: generatablePackage)
        let packageProducts = try obtainPackageProducts(generatablePackage: generatablePackage)
        
        output.append("// swift-tools-version:" + generatablePackage.packageJsonFile.swiftToolsVersion)
        output.append("import PackageDescription")
        output.append("")
        
        output.append("var targets = [Target]()")
        let targetStatements: [String] = try packageTargets.flatMap { target -> [String] in
            var statements = [String]()
            if let conditionalCompilationTargetRequirement = target.conditionalCompilationTargetRequirement {
                statements.append("#if " + conditionalCompilationTargetRequirement.statement)
            }

            let targetMethodName: String
            if target.isTest {
                targetMethodName = ".testTarget("
            } else if isExecutableTarget(target: target, products: packageProducts) {
                targetMethodName = ".executableTarget("
            } else {
                targetMethodName = ".target("
            }

            statements.append("// MARK: \(target.name)")
            statements.append("targets.append(")
            statements.append("    " + targetMethodName)
            statements.append("        name: \"\(target.name)\",")
            statements.append("        dependencies: [")
            statements.append(
                contentsOf: try target.dependencies
                    .compactMap { importedModuleName -> ImportedDependency? in
                        if generatablePackage.packageJsonFile.dependencies.implicitSystemModules.contains(importedModuleName) {
                            return nil
                        }
                        
                        for (externalPackageName, requirement) in generatablePackage.packageJsonFile.dependencies.external {
                            if let cachedValue = importedDependencyCache[importedModuleName] {
                                return cachedValue
                            }
                            
                            switch requirement {
                            case let .url(_, _, importMappings, targetNames):
                                switch targetNames {
                                case let .targetNames(targetNames):
                                    if targetNames.contains(importedModuleName) {
                                        let result = ImportedDependency.fromExternalPackage(moduleName: importedModuleName, importMappings: importMappings, packageName: externalPackageName)
                                        importedDependencyCache[importedModuleName] = result
                                        return result
                                    }
                                case .generated:
                                    let externalCheckoutPath = generatablePackage.checkout(forPackage: externalPackageName)
                                    let anotherPackage = try GeneratablePackage(location: externalCheckoutPath)
                                    anotherPackagesReferencedByPackageBeingGenerated.insert(anotherPackage)
                                    if let importedDependency = try importedDependency(
                                        forImportedModuleName: importedModuleName,
                                        requiredBy: generatablePackage.packageJsonFile,
                                        ifProvidedByAnotherGeneratablePackage: anotherPackage
                                    ) {
                                        importedDependencyCache[importedModuleName] = importedDependency
                                        return importedDependency
                                    }
                                }
                                continue
                            case let .local(path, targetNames):
                                switch targetNames {
                                case let .targetNames(providedTargetNames):
                                    if providedTargetNames.contains(importedModuleName) {
                                        let result = ImportedDependency.fromExternalPackage(moduleName: importedModuleName, importMappings: [:], packageName: externalPackageName)
                                        importedDependencyCache[importedModuleName] = result
                                        return result
                                    }
                                case .generated:
                                    let onDiskGeneratablePackagePath = generatablePackage.location.appendingPathComponent(path, isDirectory: true)
                                    let anotherPackage = try GeneratablePackage(location: onDiskGeneratablePackagePath)
                                    anotherPackagesReferencedByPackageBeingGenerated.insert(anotherPackage)
                                    if let importedDependency = try importedDependency(
                                        forImportedModuleName: importedModuleName,
                                        requiredBy: generatablePackage.packageJsonFile,
                                        ifProvidedByAnotherGeneratablePackage: anotherPackage
                                    ) {
                                        importedDependencyCache[importedModuleName] = importedDependency
                                        return importedDependency
                                    }
                                }
                                continue
                            }
                        }
                        
                        let result = ImportedDependency.fromSamePackage(moduleName: importedModuleName)
                        importedDependencyCache[importedModuleName] = result
                        return result
                    }
                    .map { IndentedStatement(level: 3, string: $0.statement + ",").statement }
                    .removeDuplicates()
                    .sorted()
            )
            statements.append("        ],")
            statements.append("        path: \"\(target.path)\"" + (target.settings.linkerSettings.isDefined ? "," : ""))
            
            if target.settings.linkerSettings.isDefined {
                statements.append("        linkerSettings: [")
                statements.append(contentsOf: target.settings.linkerSettings.statements.map { "            " + $0 + "," })
                statements.append("        ]")
            }
            
            statements.append("    )")
            statements.append(")")
            if target.conditionalCompilationTargetRequirement != nil {
                statements.append("#endif")
            }
            return statements
        }
        output.append(contentsOf: targetStatements.map { IndentedStatement(level: 0, string: $0).statement })
        
        output.append("")
        output.append("let package = Package(")
        output.append("    name: \"\(generatablePackage.packageJsonFile.name)\",")
        output.append("    platforms: [")
        output.append(contentsOf: generatablePackage.packageJsonFile.platforms.map { "        \($0.statement)," })
        output.append("    ],")
        output.append("    products: [")
        output.append(contentsOf: packageProducts.map { "        \($0.statement)," })
        output.append("    ],")
        output.append("    dependencies: [")
        output.append(contentsOf: generatablePackage.packageJsonFile.dependencies.statements.map { IndentedStatement(level: 2, string: $0 + ",").statement })
        output.append("    ],")
        output.append("    targets: targets")
        output.append(")")
        output.append("")
        
        try prepareMirrorsFileIfNeeded(generatablePackage: generatablePackage)
        
        try didGenerate(generatablePackage: generatablePackage)
        
        let result = Set(try anotherPackagesReferencedByPackageBeingGenerated.flatMap { referencedGeneratedPackage in
            try generatePackageSwiftCode(generatablePackage: referencedGeneratedPackage)
        }).union([
            GeneratedPackageContents(
                contents: output.joined(separator: "\n"),
                package: generatablePackage
            )
        ])
        return result
    }
    
    private func willGenerate(generatablePackage: GeneratablePackage) throws {
        try execute(executableFileUrl: generatablePackage.preflightExecutableUrl, contextPackage: generatablePackage)
    }
    
    private func didGenerate(generatablePackage: GeneratablePackage) throws {
        try execute(executableFileUrl: generatablePackage.postflightExecutableUrl, contextPackage: generatablePackage)
    }
    
    private func execute(executableFileUrl: URL, contextPackage: GeneratablePackage) throws {
        if FileManager().fileExists(atPath: executableFileUrl.path) {
            log("Executing executable \(executableFileUrl.path)")
            let process = Process()
            process.launchPath = executableFileUrl.path
            process.currentDirectoryURL = contextPackage.location
            try process.run()
            process.waitUntilExit()
        }
    }
    
    private func prepareMirrorsFileIfNeeded(generatablePackage: GeneratablePackage) throws {
        guard let mirrorsFilePath = generatablePackage.packageJsonFile.dependencies.mirrorsFilePath
                ?? defaultMirrorsFilePathIfExists(generatablePackage: generatablePackage)
        else { return }
        
        try FileManager().createDirectory(
            at: generatablePackage.mirrorsFile_xcode13_3.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        struct Mirrors: Codable {
            let object: [ObjectItem]
            let version: Int
        }
        
        struct ObjectItem: Codable {
            let mirror: URL
            let original: URL
        }
        
        let mirrorsFileData = try Data(contentsOf: URL(fileURLWithPath: mirrorsFilePath, isDirectory: false))
        
        let mirrors = try JSONDecoder().decode(
            Mirrors.self,
            from: mirrorsFileData
        )
        
        let newObject = try mirrors.object.flatMap { (objectItem: ObjectItem) -> [ObjectItem] in
            // order of suffixes matters, each suffix should be a substring of some previous one
            let suffixes = [".git/", ".git", "/", ""]
            
            var originalURLAbsoluteString = objectItem.original.absoluteString
            
            if let suffixRange = suffixes.compactMap({ suffix in
                objectItem.original.absoluteString.range(of: suffix)
            }).first {
                originalURLAbsoluteString.removeSubrange(suffixRange)
            }
            
            return try suffixes.map { suffix in
                guard let original = URL(string: originalURLAbsoluteString + suffix) else {
                    throw "URL(string: \(originalURLAbsoluteString + suffix)) returned nil"
                }
                return ObjectItem(
                    mirror: objectItem.mirror,
                    original: original
                )
            }
        }
        
        let newMirrors = Mirrors(
            object: newObject,
            version: mirrors.version
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let newMirrorsData = try encoder.encode(newMirrors)
        
        try? FileManager().removeItem(at: generatablePackage.mirrorsFile_xcode13_3)
        try newMirrorsData.write(to: generatablePackage.mirrorsFile_xcode13_3, options: .atomic)
    }
    
    private func defaultMirrorsFilePathIfExists(generatablePackage: GeneratablePackage) -> String? {
        let allDirectoriesFromPackageToRoot = sequence(first: generatablePackage.location.standardizedFileURL) {
            let next = $0.deletingLastPathComponent()
            return next == URL(fileURLWithPath: "/..", isDirectory: true) ? nil : next
        }
        
        let defaultMirrorsFilePath = allDirectoriesFromPackageToRoot
            .map { $0.appendingPathComponent(PackageDependencies.defaultMirrorsFileName, isDirectory: false) }
            .first { (try? $0.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true }
        
        return defaultMirrorsFilePath?.absoluteString.replacingOccurrences(of: "file://", with: "")
    }
    
    private func importedDependency(
        forImportedModuleName importedModuleName: String,
        requiredBy packageJsonFile: PackageJsonFile,
        ifProvidedByAnotherGeneratablePackage anotherPackage: GeneratablePackage
    ) throws -> ImportedDependency? {
        let anotherPackageName = anotherPackage.packageJsonFile.name
        
        let exportedProducts = try obtainPackageProducts(
            generatablePackage: anotherPackage
        )
        log("Looking for package for external module \(importedModuleName) required by \(packageJsonFile.name) inside \(anotherPackageName)")
        if exportedProducts.contains(where: { $0.name == importedModuleName }) {
            log("    External module \(importedModuleName) is provided by \(anotherPackageName)")
            return ImportedDependency.fromExternalPackage(moduleName: importedModuleName, importMappings: [:], packageName: anotherPackageName)
        }
        return nil
    }
    
    private func obtainPackageTargets(
        generatablePackage: GeneratablePackage
    ) throws -> [PackageTarget] {
        try obtainPackageTargets(
            packageTargets: generatablePackage.packageJsonFile.targets,
            generatablePackageLocation: generatablePackage.location
        )
    }
    
    private func obtainPackageTargets(
        packageTargets: PackageTargets,
        generatablePackageLocation: URL
    ) throws -> [PackageTarget] {
        switch packageTargets {
        case let .multiple(packageTargets):
            return try packageTargets.flatMap {
                try obtainPackageTargets(
                    packageTargets: $0,
                    generatablePackageLocation: generatablePackageLocation
                )
            }
        case let .single(target):
            return [target]
        case .discoverAutomatically:
            if let result = packageTargetCache[generatablePackageLocation] {
                return result
            }
            
            let result = try PackageTarget.discoverTargets(packageLocation: generatablePackageLocation).sorted(by: { left, right -> Bool in
                left.name < right.name
            })
            packageTargetCache[generatablePackageLocation] = result
            return result
        }
    }

    private func isExecutableTarget(target: PackageTarget, products: [PackageProduct]) -> Bool {
        return products.lazy
            .filter { $0.productType == .executable }
            .contains { product in
                product.targets.contains(target.name)
            }
    }

    private func obtainPackageProducts(
        generatablePackage: GeneratablePackage
    ) throws -> [PackageProduct] {
        switch generatablePackage.packageJsonFile.products {
        case let .explicit(products):
            return products
        case .productForEachTarget:
            let packageTargets = try obtainPackageTargets(generatablePackage: generatablePackage)
            return packageTargets.filter { !$0.isTest }.map { packageTarget in
                PackageProduct(
                    name: packageTarget.name,
                    productType: .library,
                    targets: [
                        packageTarget.name
                    ]
                )
            }
        }
    }
    
    private enum ImportedDependency: Hashable, Comparable {
        case fromSamePackage(moduleName: String)
        case fromExternalPackage(moduleName: String, importMappings: [String: String], packageName: String)
        
        var statement: String {
            switch self {
            case let .fromSamePackage(moduleName):
                return "\"\(moduleName)\""
            case let .fromExternalPackage(moduleName, importMappings, packageName):
                let moduleName = importMappings[moduleName] ?? moduleName
                return ".product(name: \"\(moduleName)\", package: \"\(packageName)\")"
            }
        }
        
        var moduleName: String {
            switch self {
            case let .fromSamePackage(moduleName):
                return moduleName
            case let .fromExternalPackage(moduleName, _, _):
                return moduleName
            }
        }
        
        static func < (left: Self, right: Self) -> Bool {
            left.moduleName < right.moduleName
        }
    }
}
