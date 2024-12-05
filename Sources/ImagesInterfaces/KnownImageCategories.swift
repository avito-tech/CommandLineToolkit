import PathLib

public protocol KnownImageCategories {
    var moduleName: String { get }
    var factoryFileName: String { get }
    var assetContentFileName: String { get }
    var assetsPath: RelativePath { get }
    var imageFactoryPath: RelativePath { get }
    var assetsExtention: String { get }
    var imagesetExtention: String { get }
    var all: [KnownImageCategory] { get }
}

public struct KnownImageCategory: Equatable {
    public let name: String
    public let path: RelativePath
    
    public init(name: String, path: RelativePath) {
        self.name = name
        self.path = path
    }
}
