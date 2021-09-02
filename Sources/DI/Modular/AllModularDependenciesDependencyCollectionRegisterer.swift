public final class AllModularDependenciesDependencyCollectionRegisterer: DependencyCollectionRegisterer {
    private let moduleDependencies: ModuleDependencies
    
    public init(moduleDependencies: ModuleDependencies) {
        self.moduleDependencies = moduleDependencies
    }
    
    public func register(dependencyRegisterer di: DependencyRegisterer) {
        dependenciesFromTopMostToBottomMost(
            moduleDependencies: moduleDependencies
        ).reversed().forEach {
            $0.registerDependenciesOfCurrentModule(di: di)
        }
    }
    
    private func dependenciesFromTopMostToBottomMost(
        moduleDependencies: ModuleDependencies
    ) -> [CurrentModuleDependenciesRegisterer] {
        let moduleDependenciesSearchResult = ModuleDependenciesSearchContext()
        
        moduleDependenciesSearchResult.append(moduleDependencies: moduleDependencies)
        
        return moduleDependenciesSearchResult.dependenciesFromTopMostToBottomMost
    }
}

private final class ModuleDependenciesSearchContext {
    private var visitedDependenciesIdentifiers = Set<AnyHashable>()
    private(set) var dependenciesFromTopMostToBottomMost = [CurrentModuleDependenciesRegisterer]()
    
    func append(moduleDependencies: ModuleDependencies) {
        append(
            currentModuleDependenciesRegisterer: moduleDependencies,
            identifier: moduleDependencies.identifier
        )
        moduleDependencies.otherModulesDependecies().forEach {
            append(moduleDependencies: $0)
        }
    }
    
    func append(
        currentModuleDependenciesRegisterer: CurrentModuleDependenciesRegisterer,
        identifier: AnyHashable)
    {
        if visitedDependenciesIdentifiers.insert(identifier).inserted {
            dependenciesFromTopMostToBottomMost.append(currentModuleDependenciesRegisterer)
        }
    }
}
