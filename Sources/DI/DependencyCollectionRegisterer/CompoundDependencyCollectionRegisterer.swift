public final class CompoundDependencyCollectionRegisterer: DependencyCollectionRegisterer {
    private let registerers: [DependencyCollectionRegisterer]
    
    public init(registerers: [DependencyCollectionRegisterer]) {
        self.registerers = registerers
    }
    
    public func register(dependencyRegisterer: DependencyRegisterer) {
        registerers.forEach {
            $0.register(dependencyRegisterer: dependencyRegisterer)
        }
    }
}
