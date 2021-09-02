import DI
import Foundation

public final class EnvironmentModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: ProcessInfo.self) { _ in
            ProcessInfo.processInfo
        }
        di.register(type: CurrentExecutableProvider.self) { di in
            try ProcessInfoCurrentExecutableProvider(
                processInfo: di.resolve()
            )
        }
        di.register(type: EnvironmentProvider.self) { di in
            try ProcessInfoEnvironmentProvider(
                processInfo: di.resolve()
            )
        }
    }
}
