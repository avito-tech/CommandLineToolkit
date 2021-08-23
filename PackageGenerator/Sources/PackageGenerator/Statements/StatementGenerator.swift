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
        output.append("    targets: [")
        let targetStatements: [String] = try packageTargets.flatMap { target -> [String] in
            var statements = [String]()
            statements.append(!target.isTest ? ".target(" : ".testTarget(")
            statements.append("    name: \"\(target.name)\",")
            statements.append("    dependencies: [")
            statements.append(
                contentsOf: try target.dependencies.compactMap { importedModuleName -> ImportedDependency? in
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
                                let externalCheckoutPath = generatablePackage.location.appendingPathComponent(".build/checkouts/\(externalPackageName)/", isDirectory: true)
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
                }.sorted().map { IndentedStatement(level: 2, string: $0.statement + ",").statement }
            )
            statements.append("    ],")
            statements.append("    path: \"\(target.path)\"" + (target.settings.linkerSettings.isDefined ? "," : ""))
            
            if target.settings.linkerSettings.isDefined {
                statements.append("    linkerSettings: [")
                statements.append(contentsOf: target.settings.linkerSettings.statements.map { "        " + $0 + "," })
                statements.append("    ]")
            }
            
            statements.append("),")
            return statements
        }
        output.append(contentsOf: targetStatements.map { IndentedStatement(level: 2, string: $0).statement })
        output.append("    ]")
        
        output.append(")")
        output.append("")
        
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
        switch generatablePackage.packageJsonFile.targets {
        case let .explicit(targets):
            return targets
        case .discoverAutomatically:
            if let result = packageTargetCache[generatablePackage.location] {
                return result
            }
            
            let result = try PackageTarget.discoverTargets(packageLocation: generatablePackage.location).sorted(by: { left, right -> Bool in
                left.name < right.name
            })
            packageTargetCache[generatablePackage.location] = result
            return result
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

public extension LinkerSettings {
    var statements: [String] {
        var result = [String]()
        if !unsafeFlags.isEmpty {
            result.append(".unsafeFlags([" + unsafeFlags.map { "\"\($0)\"" }.joined(separator: ", ") + "])")
        }
        return result
    }
}
