public protocol DependencyResolver: AnyObject {
    // Use this function in custom implementations/wrappers of `DependencyResolver`.
    // See `CompoundDependencyResolver`. Use `resolve<T>()` for everything else, for
    // example, for resolving your dependencies.
    func resolve<T>(nestedDependencyResolver: DependencyResolver) throws -> T
}

extension DependencyResolver {
    // Use this function for most cases.
    public func resolve<T>(type: T.Type = T.self) throws -> T {
        return try resolve(nestedDependencyResolver: self)
    }
}
