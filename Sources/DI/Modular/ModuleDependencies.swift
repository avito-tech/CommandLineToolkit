public protocol ModuleDependencies: CurrentModuleDependenciesRegisterer, OtherModuleDependenciesProvider {
    var identifier: AnyHashable { get }
}

public protocol CurrentModuleDependenciesRegisterer {
    func registerDependenciesOfCurrentModule(di: DependencyRegisterer)
}

public protocol OtherModuleDependenciesProvider {
    func otherModulesDependecies() -> [ModuleDependencies]
}

extension ModuleDependencies {
    public var identifier: AnyHashable {
        return HashableType(type: type(of: self))
    }
}

extension OtherModuleDependenciesProvider {
    public func otherModulesDependecies() -> [ModuleDependencies] {
        return []
    }
}
