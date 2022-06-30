public final class DiMaker<T> where
    T: ModuleDependencies,
    T: InitializableWithNoArguments
{
    public static func makeDi() -> DependencyInjection {
        let di = DependencyInjectionImpl()
        
        let registerer = AllModularDependenciesDependencyCollectionRegisterer(
            moduleDependencies: T()
        )
        
        registerer.register(dependencyRegisterer: di)
        
        return di
    }
}
