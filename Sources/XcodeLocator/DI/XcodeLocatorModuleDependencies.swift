import DI
import Foundation
import FileSystem

public final class XcodeLocatorModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func otherModulesDependecies() -> [ModuleDependencies] {
        [
            FileSystemModuleDependencies(),
        ]
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        di.register(type: XcodeApplicationVerifier.self) { _ in
            XcodeApplicationVerifierImpl()
        }
        di.register(type: XcodeLocator.self) { di in
            try XcodeLocatorImpl(
                applicationPathsProvider: di.resolve(),
                xcodeApplicationVerifier: di.resolve(),
                applicationPlistReader: di.resolve()
            )
        }
        di.register(type: ApplicationPlistReader.self) { _ in
            ApplicationPlistReaderImpl()
        }
        di.register(type: ApplicationPathsProvider.self) { di in
            try ApplicationPathsProviderImpl(
                commonlyUsedPathsProvider: di.resolve(),
                fileSystemEnumeratorFactory: di.resolve()
            )
        }
    }
}
