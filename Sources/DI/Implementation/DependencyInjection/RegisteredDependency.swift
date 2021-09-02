final class RegisteredDependency {
    let scope: Scope
    let factory: (DependencyResolver) throws -> Any
    let instance: Any?
    
    init(
        scope: Scope,
        factory: @escaping (DependencyResolver) throws -> Any,
        instance: Any?)
    {
        self.scope = scope
        self.factory = factory
        self.instance = instance
    }
}
