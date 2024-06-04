import DI
import TeamcityMessaging

public final class ConsoleModuleDependencies: ModuleDependencies {
    public init() {
    }

    public func otherModulesDependecies() -> [any ModuleDependencies] {
        [TeamcityMessagingModuleDependencies()]
    }

    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: Console.self) {
            Console()
        }
    }
}
