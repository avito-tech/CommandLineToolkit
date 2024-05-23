/// Holds global DI container, in a safe manner
public final class DiContext: DependencyResolver {
    @TaskLocal public static var current: DiContext = .init()

    var container: DependencyInjectionImpl = .init()

    init() {}

    init(
        parent: DiContext,
        register: (DependencyRegisterer) -> ()
    ) {
        // Create a copy, so external scope will remain untouched
        self.container = DependencyInjectionImpl(container: parent.container)
        register(container)
    }

    public func resolve<T>(nestedDependencyResolver: any DependencyResolver) throws -> T {
        try container.resolve(nestedDependencyResolver: nestedDependencyResolver)
    }
}

/// Allows to register dependencies in a global di context, for duration of operation
public func withDependencies<Value>(
    register: (DependencyRegisterer) -> (),
    operation: () async throws -> Value
) async rethrows -> Value {
    try await DiContext.$current.withValue(DiContext(parent: DiContext.current, register: register), operation: operation)
}

/// Allows to register dependencies in a global di context, for duration of operation
public func withDependencies<Value>(
    register: (DependencyRegisterer) -> (),
    operation: () throws -> Value
) rethrows -> Value {
    try DiContext.$current.withValue(DiContext(parent: DiContext.current, register: register), operation: operation)
}

private func registerDependencies(from modules: [any ModuleDependencies]) -> (DependencyRegisterer) -> () {
    return { di in
        for module in modules {
            let registerer = AllModularDependenciesDependencyCollectionRegisterer(
                moduleDependencies: module
            )
            registerer.register(dependencyRegisterer: di)
        }
    }
}

/// Allows to register module dependencies in a global di context, for duration of operation
public func withDependencies<Value>(
    from modules: [any ModuleDependencies],
    operation: () async throws -> Value
) async rethrows -> Value {
    try await withDependencies(
        register: registerDependencies(from: modules),
        operation: operation
    )
}

/// Allows to register module dependencies in a global di context, for duration of operation
public func withDependencies<Value>(
    from modules: [any ModuleDependencies],
    operation: () throws -> Value
) rethrows -> Value {
    try withDependencies(
        register: registerDependencies(from: modules),
        operation: operation
    )
}
