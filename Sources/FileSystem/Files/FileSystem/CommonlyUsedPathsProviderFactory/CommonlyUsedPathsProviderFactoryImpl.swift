import Foundation

public final class CommonlyUsedPathsProviderFactoryImpl: CommonlyUsedPathsProviderFactory {
    public init() {
    }
    
    public var commonlyUsedPathsProvider: CommonlyUsedPathsProvider {
#if os(macOS)
        return AppleCommonlyUsedPathsProvider()
#elseif os(Linux)
        return LinuxCommonlyUsedPathsProvider()
#else
        #error("Unsupported OS")
#endif
    }
}
