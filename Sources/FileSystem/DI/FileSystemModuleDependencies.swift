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
        di.register(scope: .unique, type: FileManager.self) { _ in
            FileManager()
        }
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
                fileToucher: di.resolve()
            )
        }
        di.register(type: FileSystemEnumeratorFactory.self) { di in
            try FileSystemEnumeratorFactoryImpl(
                fileManager: di.resolve()
            )
        }
        di.register(type: DirectoryCreator.self) { di in
            try DirectoryCreatorImpl(
                fileManager: di.resolve(),
                filePropertiesProvider: di.resolve()
            )
        }
        di.register(type: FileCreator.self) { di in
            try FileCreatorImpl(
                fileManager: di.resolve()
            )
        }
        di.register(type: PathCopier.self) { di in
            try PathCopierImpl(
                fileManager: di.resolve(),
                pathDeleter: di.resolve(),
                directoryCreator: di.resolve()
            )
        }
        di.register(type: PathMover.self) { di in
            try PathMoverImpl(
                fileManager: di.resolve(),
                pathDeleter: di.resolve(),
                directoryCreator: di.resolve()
            )
        }
        di.register(type: PathDeleter.self) { di in
            try PathDeleterImpl(
                fileManager: di.resolve(),
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
        di.register(type: CommonlyUsedPathsProviderFactory.self) { di in
            try CommonlyUsedPathsProviderFactoryImpl(
                fileManager: di.resolve()
            )
        }
        di.register(type: FileToucher.self) { di in
            try FileToucherImpl(
                filePropertiesProvider: di.resolve(),
                fileCreator: di.resolve()
            )
        }
        di.register(type: CommonlyUsedPathsProvider.self) { di in
            try DefaultCommonlyUsedPathsProvider(
                fileManager: di.resolve()
            )
        }
    }
}
