import PathLib

public protocol ImageSetGenerator {
    func generateAssets(
        from source: ImageSource,
        selectedCategory: KnownImageCategory,
        selectedRenderingMode: ImageRenderingMode,
        isVector: Bool,
        knownImageCategories: KnownImageCategories
    ) throws
}

public struct ImageSource: Equatable {
    public struct MultiThemePath: Equatable {
        public let light: AbsolutePath
        public let dark: AbsolutePath?
        
        public init(light: AbsolutePath, dark: AbsolutePath? = nil) {
            self.light = light
            self.dark = dark
        }
    }
    
    public let rootPath: AbsolutePath
    public let imageFilePaths: [MultiThemePath]
    
    public init(rootPath: AbsolutePath, imageFilePaths: [ImageSource.MultiThemePath]) {
        self.rootPath = rootPath
        self.imageFilePaths = imageFilePaths
    }
}

public enum ImageRenderingMode: String, CaseIterable {
    case `default`
    case original
    case template
}
