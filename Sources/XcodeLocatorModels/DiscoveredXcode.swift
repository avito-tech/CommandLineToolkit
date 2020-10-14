import PathLib

public struct DiscoveredXcode: Hashable {
    public let path: AbsolutePath
    public let shortVersion: String
    
    public init(
        path: AbsolutePath,
        shortVersion: String
    ) {
        self.path = path
        self.shortVersion = shortVersion
    }
}
