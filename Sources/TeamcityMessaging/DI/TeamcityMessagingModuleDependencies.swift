import DI

public final class TeamcityMessagingModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: TeamcityMessageGenerator.self) { _ in
            TeamcityMessageGenerator()
        }
        di.register(type: TeamcityMessagingOutput.self) { di in
            try TeamcityMessagingOutputImpl(
                teamcityMessageRenderer: di.resolve()
            )
        }
        di.register(type: TeamcityMessageRenderer.self) { _ in
            TeamcityMessageRendererImpl()
        }
        di.register(type: TeamcityMessaging.self) { di in
            try TeamcityMessagingImpl(
                teamcityMessageGenerator: di.resolve(),
                teamcityMessagingOutput: di.resolve()
            )
        }
    }
}
