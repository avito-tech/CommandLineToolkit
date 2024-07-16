import DI
import Foundation

public final class FileSystemModuleDependencies: ModuleDependencies {
    public init() {
    }
    
    public func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
        registerDepedenciesForWorkingWithPaths(di: di)
        registerDepedenciesForWorkingWithContentsOfFile(di: di)
        registerDepedenciesForWorkingWithFiles(di: di)
    }
    
    private func registerDepedenciesForWorkingWithPaths(di: DependencyRegisterer) {
        di.register(type: RealpathProvider.self) { _ in
            RealpathProviderImpl()
        }
    }
    
    private func registerDepedenciesForWorkingWithContentsOfFile(di: DependencyRegisterer) {
        di.register(type: FileReader.self) { _ in
            FileReaderImpl()
        }
        di.register(type: DataWriter.self) { di in
            try DataWriterImpl(
                directoryCreator: di.resolve()
            )
        }
    }
    
    private func registerDepedenciesForWorkingWithFiles(di: DependencyRegisterer) {
        di.register(type: FileSystem.self) { di in
            try LocalFileSystem(
                fileSystemEnumeratorFactory: di.resolve(),
                directoryCreator: di.resolve(),
                fileCreator: di.resolve(),
                pathCopier: di.resolve(),
                pathMover: di.resolve(),
                pathDeleter: di.resolve(),
                filePropertiesProvider: di.resolve(),
                fileSystemPropertiesProvider: di.resolve(),
                commonlyUsedPathsProviderFactory: di.resolve(),
                fileToucher: di.resolve(),
                pathLinker: di.resolve(),
                fileAppender: di.resolve()
            )
        }
        di.register(type: FileSystemEnumeratorFactory.self) { di in
            try FileSystemEnumeratorFactoryImpl(
                filePropertiesProvider: di.resolve()
            )
        }
        di.register(type: DirectoryCreator.self) { di in
            try DirectoryCreatorImpl(
                filePropertiesProvider: di.resolve()
            )
        }
        di.register(type: FileCreator.self) { _ in
            FileCreatorImpl()
        }
        di.register(type: FileAppender.self) { _ in
            FileAppenderImpl()
        }
        di.register(type: PathCopier.self) { di in
            try PathCopierImpl(
                pathDeleter: di.resolve(),
                directoryCreator: di.resolve()
            )
        }
        di.register(type: PathMover.self) { di in
            try PathMoverImpl(
                pathDeleter: di.resolve(),
                directoryCreator: di.resolve()
            )
        }
        di.register(type: PathDeleter.self) { di in
            try PathDeleterImpl(
                filePropertiesProvider: di.resolve()
            )
        }
        di.register(type: FileSystemPropertiesProvider.self) { _ in
            FileSystemPropertiesProviderImpl()
        }
        di.registerMultiple(type: FilePropertiesProvider.self) { _ in
            FilePropertiesProviderImpl()
        }.reregister {
            $0 as FileExistenceChecker
        }
        di.register(type: CommonlyUsedPathsProviderFactory.self) { _ in
            CommonlyUsedPathsProviderFactoryImpl()
        }
        di.register(type: FileToucher.self) { di in
            try FileToucherImpl(
                filePropertiesProvider: di.resolve(),
                fileCreator: di.resolve()
            )
        }
        di.register(type: CommonlyUsedPathsProvider.self) { di in
            let factory = try di.resolve() as CommonlyUsedPathsProviderFactory
            return factory.commonlyUsedPathsProvider
        }
        di.register(type: PathLinker.self) { di in
            try PathLinkerImpl(
                pathDeleter: di.resolve(),
                directoryCreator: di.resolve()
            )
        }
    }
}
