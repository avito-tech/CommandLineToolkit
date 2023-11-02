import DI

public final class DownloaderModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: Downloader.self) { di in
            DownloaderImpl(dateProvider: try di.resolve())
        }
    }
}
