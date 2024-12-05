import ImagesInterfaces
import PathLib

public struct KnownImageCategoriesMock: KnownImageCategories {
    
    public init() {}
    
    public var moduleName: String {
        "mockModuleName"
    }
    public var factoryFileName: String {
        "mockfactoryFileName"
    }
    public var assetContentFileName: String {
        "mockAssetContentFileName"
    }
    public var assetsPath: RelativePath {
        RelativePath(components: ["mock/assets/path"])
    }
    public var imageFactoryPath: RelativePath {
        RelativePath(components: ["mockImageFactoryPath"])
    }
    public var assetsExtention: String {
        "mockAssetsExtention"
    }
    public var imagesetExtention: String {
        "mockImagesetExtention"
    }
    public var all: [KnownImageCategory] {
        [
            KnownImageCategory(
                name: "MockCategory1",
                path: "\(assetsPath)/MockCategory1"
            ),
            KnownImageCategory(
                name: "MockCategory2",
                path: "\(assetsPath)/MockCategory2"
            )
        ]
    }
}
