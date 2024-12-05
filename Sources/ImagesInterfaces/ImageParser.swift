import PathLib

public protocol ImageParser {
    func imageSource(rootPath: AbsolutePath) throws -> ImageSource
    func assetSource(consoleInput: String, assetsPath: RelativePath) throws -> AbsolutePath
}
