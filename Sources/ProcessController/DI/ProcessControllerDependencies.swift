import DI
import FileSystem
import DateProvider

public final class ProcessControllerModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func otherModulesDependecies() -> [ModuleDependencies] {
        [
            DateProviderModuleDependencies(),
            FileSystemModuleDependencies()
        ]
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: ProcessControllerProvider.self) { di in
            try DefaultProcessControllerProvider(
                dateProvider: di.resolve(),
                filePropertiesProvider: di.resolve()
            )
        }
        di.register(type: BashEscapedCommandMaker.self) { _ in
            BashEscapedCommandMakerImpl()
        }
    }
}
