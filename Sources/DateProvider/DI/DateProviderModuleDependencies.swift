import DI

public final class DateProviderModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: DateProvider.self) { _ in
            SystemDateProvider()
        }
    }
}
