import DI

public final class TeamcityMessagingModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: TeamcityMessageGenerator.self) { _ in
            TeamcityMessageGenerator()
        }
        di.register(type: TeamcityMessageRenderer.self) { _ in
            TeamcityMessageRendererImpl()
        }
    }
}
