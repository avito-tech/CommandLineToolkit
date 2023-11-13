import DI
import ProcessController
import Environment

public final class MutualTLSModuleDependencies: ModuleDependencies {
    public init() {
    }

    public func otherModulesDependecies() -> [ModuleDependencies] {
        [
            ProcessControllerModuleDependencies(),
            EnvironmentModuleDependencies(),
        ]
    }

    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: MutualTLSCredentialProvider.self) { di in
            try MutualTLSCredentialProviderImpl(
                processControllerProvider: di.resolve(),
                environmentProvider: di.resolve()
            )
        }
    }
}
