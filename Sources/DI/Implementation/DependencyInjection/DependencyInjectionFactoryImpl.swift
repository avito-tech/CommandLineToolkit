public final class DependencyInjectionFactoryImpl: DependencyInjectionFactory {
    public init() {
    }
    
    public func dependencyInjection() -> DependencyInjection {
        return DependencyInjectionImpl()
    }
}
