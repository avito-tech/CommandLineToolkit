import Foundation

public final class CommonlyUsedPathsProviderFactoryImpl: CommonlyUsedPathsProviderFactory {
    private let fileManager: FileManager
    
    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }
    
    public var commonlyUsedPathsProvider: CommonlyUsedPathsProvider {
#if os(macOS)
        return AppleCommonlyUsedPathsProvider(fileManager: fileManager)
#elseif os(Linux)
        return LinuxCommonlyUsedPathsProvider(fileManager: fileManager)
#else
        #error("Unsupported OS")
#endif
    }
}
