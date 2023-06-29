import DI

public final class ConsoleModuleDependencies: ModuleDependencies {
    public init() {
    }

    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: Console.self) {
            Console()
        }
    }
}
