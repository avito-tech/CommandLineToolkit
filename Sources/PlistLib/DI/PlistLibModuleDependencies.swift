import DI

public final class PlistLibModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: PlistReader.self) { di in
            try PlistReaderImpl(
                fileReader: di.resolve()
            )
        }
    }
}
