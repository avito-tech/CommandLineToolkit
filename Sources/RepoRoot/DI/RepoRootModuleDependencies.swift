import DI
import FileSystem
import ProcessController
import Environment

public final class RepoRootModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: RepoRootProviderFactory.self) { di in
            try CachingRepoRootProviderFactory(
                repoRootProviderFactory: MarkerFileRepoRootProviderFactory(
                    fileExistenceChecker: di.resolve(),
                    markerFileName: ".reporoot"
                )
            )
        }
    }
    
    public func otherModulesDependecies() -> [ModuleDependencies] {
        [
            FileSystemModuleDependencies(),
            ProcessControllerModuleDependencies(),
            EnvironmentModuleDependencies()
        ]
    }
}
