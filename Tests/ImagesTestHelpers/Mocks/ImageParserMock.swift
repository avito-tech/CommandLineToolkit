import ImagesInterfaces
import PathLib

public final class ImageParserMock: ImageParser {
    
    public var inputSourcePath: AbsolutePath?
    public var inputAssetsSourcePath: String?
    public var inputAssetsSourceAssetsPath: RelativePath?
    public private(set) var assetSourceInputs: [(consoleInput: String, assetsPath: RelativePath)] = []
    private var assetSourceCallIndex: Int = 0
    
    // swiftlint:disable implicitly_unwrapped_optional
    public var imageSourceResult: ImageSource!
    public var assetSourceResult: AbsolutePath!
    public var assetSourceResults: [AbsolutePath] = []
    
    public init() {}
    
    public func imageSource(rootPath: AbsolutePath) throws -> ImageSource {
        inputSourcePath = rootPath
        return imageSourceResult
    }
    
    public func assetSource(consoleInput: String, assetsPath: RelativePath) throws -> AbsolutePath {
        inputAssetsSourcePath = consoleInput
        inputAssetsSourceAssetsPath = assetsPath
        assetSourceInputs.append((consoleInput: consoleInput, assetsPath: assetsPath))
        defer { assetSourceCallIndex += 1 }
        if assetSourceCallIndex < assetSourceResults.count {
            return assetSourceResults[assetSourceCallIndex]
        }
        return assetSourceResult
    }
}
