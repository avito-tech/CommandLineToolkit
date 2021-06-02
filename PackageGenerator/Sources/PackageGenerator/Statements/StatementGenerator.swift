import Foundation

public class StatementGenerator {
    private var importedDependencyCache = [String: ImportedDependency]()
    private var packageTargetCache = [URL: [PackageTarget]]()
    
    public init() {}
    
    public func generatePackageSwiftCode(
        swiftPackage: SwiftPackage,
        location: URL
    ) throws -> [String] {
        var output = [String]()
        
        let packageTargets = try obtainPackageTargets(swiftPackage: swiftPackage, location: location)
        let packageProducts = try obtainPackageProducts(swiftPackage: swiftPackage, location: location)
        
        output.append("// swift-tools-version:" + swiftPackage.swiftToolsVersion)
        output.append("import PackageDescription")
        output.append("let package = Package(")
        output.append("    name: \"\(swiftPackage.name)\",")
        output.append("    platforms: [")
        output.append(contentsOf: swiftPackage.platforms.map { "        \($0.statement)," })
        output.append("    ],")
        output.append("    products: [")
        output.append(contentsOf: packageProducts.map { "        \($0.statement)," })
        output.append("    ],")
        output.append("    dependencies: [")
        output.append(contentsOf: swiftPackage.dependencies.statements.map { IndentedStatement(level: 2, string: $0 + ",").statement })
        output.append("    ],")
        output.append("    targets: [")
        let targetStatements: [String] = try packageTargets.flatMap { target -> [String] in
            var statements = [String]()
            statements.append(!target.isTest ? ".target(" : ".testTarget(")
            statements.append("    name: \"\(target.name)\",")
            statements.append("    dependencies: [")
            statements.append(
                contentsOf: try target.dependencies.compactMap { importedModuleName -> ImportedDependency? in
                    if swiftPackage.dependencies.implicitSystemModules.contains(importedModuleName) {
                        return nil
                    }
                    
                    for (externalPackageName, requirement) in swiftPackage.dependencies.external {
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
                                let externalCheckoutPath = location.appendingPathComponent(".build/checkouts/\(externalPackageName)/", isDirectory: true)
                                let anotherPackage = Package(url: externalCheckoutPath)
                                let exportedProducts = try obtainPackageProducts(
                                    swiftPackage: try anotherPackage.loadSwiftPackage(),
                                    location: anotherPackage.url
                                )
                                log("Looking for package for external module \(importedModuleName) imported by \(swiftPackage.name)")
                                if exportedProducts.contains(where: { $0.name == importedModuleName }) {
                                    log("    External module \(importedModuleName) is provided by \(externalPackageName)")
                                    let result = ImportedDependency.fromExternalPackage(moduleName: importedModuleName, importMappings: [:], packageName: externalPackageName)
                                    importedDependencyCache[importedModuleName] = result
                                    return result
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
                                let anotherPackage = Package(url: location.appendingPathComponent(path, isDirectory: true))
                                let exportedProducts = try obtainPackageProducts(
                                    swiftPackage: try anotherPackage.loadSwiftPackage(),
                                    location: anotherPackage.url
                                )
                                log("Looking for package for external module \(importedModuleName) imported by \(swiftPackage.name)")
                                if exportedProducts.contains(where: { $0.name == importedModuleName }) {
                                    log("    External module \(importedModuleName) is provided by \(externalPackageName)")
                                    let result = ImportedDependency.fromExternalPackage(moduleName: importedModuleName, importMappings: [:], packageName: externalPackageName)
                                    importedDependencyCache[importedModuleName] = result
                                    return result
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
        
        return output
    }
    
    private func obtainPackageTargets(swiftPackage: SwiftPackage, location: URL) throws -> [PackageTarget] {
        switch swiftPackage.targets {
        case let .explicit(targets):
            return targets
        case .discoverAutomatically:
            if let result = packageTargetCache[location] {
                return result
            }
            
            let result = try PackageTarget.discoverTargets(packageLocation: location).sorted(by: { left, right -> Bool in
                left.name < right.name
            })
            packageTargetCache[location] = result
            return result
        }
    }

    private func obtainPackageProducts(swiftPackage: SwiftPackage, location: URL) throws -> [PackageProduct] {
        switch swiftPackage.products {
        case let .explicit(products):
            return products
        case .productForEachTarget:
            let packageTargets = try obtainPackageTargets(swiftPackage: swiftPackage, location: location)
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
