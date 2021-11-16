import PathLib
import FileSystem

public final class ApplicationPathsProviderImpl: ApplicationPathsProvider {
    private let commonlyUsedPathsProvider: CommonlyUsedPathsProvider
    private let fileSystemEnumeratorFactory: FileSystemEnumeratorFactory
    
    public init(
        commonlyUsedPathsProvider: CommonlyUsedPathsProvider,
        fileSystemEnumeratorFactory: FileSystemEnumeratorFactory
    ) {
        self.commonlyUsedPathsProvider = commonlyUsedPathsProvider
        self.fileSystemEnumeratorFactory = fileSystemEnumeratorFactory
    }
    
    public func applicationPaths() throws -> [AbsolutePath] {
        try fileSystemEnumeratorFactory.contentEnumerator(
            forPath: commonlyUsedPathsProvider.applications(
                inDomain: .local,
                create: false
            ),
            style: .shallow
        ).allPaths()
    }
}
