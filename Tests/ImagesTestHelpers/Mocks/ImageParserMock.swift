import ImagesInterfaces
import PathLib

public final class ImageParserMock: ImageParser {
    
    public var inputSourcePath: AbsolutePath?
    public var inputAssetsSourcePath: String?
    public var inputAssetsSourceAssetsPath: RelativePath?
    
    // swiftlint:disable implicitly_unwrapped_optional
    public var imageSourceResult: ImageSource!
    public var assetSourceResult: AbsolutePath!
    
    public init() {}
    
    public func imageSource(rootPath: AbsolutePath) throws -> ImageSource {
        inputSourcePath = rootPath
        return imageSourceResult
    }
    
    public func assetSource(consoleInput: String, assetsPath: RelativePath) throws -> AbsolutePath {
        inputAssetsSourcePath = consoleInput
        inputAssetsSourceAssetsPath = assetsPath
        return assetSourceResult
    }
}
