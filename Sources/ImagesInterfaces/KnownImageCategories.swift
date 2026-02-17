import PathLib

public enum ImageTargetScope: String, CaseIterable {
    case ru
    case global
}

public protocol KnownImageCategories {
    var moduleName: String { get }
    var factoryFileName: String { get }
    var assetContentFileName: String { get }
    var assetsPathByScope: [ImageTargetScope: RelativePath] { get }
    var imageFactoryPath: RelativePath { get }
    var assetsExtention: String { get }
    var imagesetExtention: String { get }
    var all: [KnownImageCategory] { get }
}

public extension KnownImageCategories {
    func assetsPath(for scope: ImageTargetScope) -> RelativePath? {
        assetsPathByScope[scope]
    }
    
    func assetsPathsForAllScopes() -> [RelativePath] {
        let scopedPaths = ImageTargetScope.allCases.compactMap { assetsPathByScope[$0] }
        var uniquePaths: [RelativePath] = []
        var seen = Set<String>()
        for path in scopedPaths {
            let key = path.pathString
            if seen.insert(key).inserted {
                uniquePaths.append(path)
            }
        }
        return uniquePaths
    }
}

public struct KnownImageCategory: Equatable {
    public let name: String
    public let path: RelativePath
    
    public init(name: String, path: RelativePath) {
        self.name = name
        self.path = path
    }
}
