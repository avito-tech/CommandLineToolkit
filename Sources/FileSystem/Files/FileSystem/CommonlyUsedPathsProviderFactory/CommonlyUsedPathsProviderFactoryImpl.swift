import Foundation

public final class CommonlyUsedPathsProviderFactoryImpl: CommonlyUsedPathsProviderFactory {
    private let fileManager: FileManager
    
    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    public var commonlyUsedPathsProvider: CommonlyUsedPathsProvider {
        return DefaultCommonlyUsedPathsProvider(fileManager: fileManager)
    }
}
