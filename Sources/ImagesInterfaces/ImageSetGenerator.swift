import PathLib

public protocol ImageSetGenerator {
    func generateAssets(
        from source: ImageSource,
        selectedCategory: KnownImageCategory,
        selectedRenderingMode: ImageRenderingMode,
        preserveVectorRepresentation: Bool,
        knownImageCategories: KnownImageCategories,
        targetScope: ImageTargetScope
    ) throws
}

public struct ImageSource: Equatable {
    public struct Asset: Equatable {
        public struct Rendition: Equatable {
            public let path: AbsolutePath
            public let appearance: ImageAppearance
            public let scale: ImageScale?

            public init(
                path: AbsolutePath,
                appearance: ImageAppearance = .light,
                scale: ImageScale? = nil
            ) {
                self.path = path
                self.appearance = appearance
                self.scale = scale
            }
        }

        public let name: String
        public let relativeDirectory: RelativePath
        public let kind: ImageAssetKind
        public let renditions: [Rendition]
        
        public init(
            name: String,
            relativeDirectory: RelativePath = RelativePath(components: [String]()),
            kind: ImageAssetKind,
            renditions: [Rendition]
        ) {
            self.name = name
            self.relativeDirectory = relativeDirectory
            self.kind = kind
            self.renditions = renditions
        }
    }
    
    public let rootPath: AbsolutePath
    public let assets: [Asset]
    
    public init(rootPath: AbsolutePath, assets: [Asset]) {
        self.rootPath = rootPath
        self.assets = assets
    }
}

public enum ImageAppearance: Equatable {
    case light
    case dark
}

public enum ImageScale: String, CaseIterable, Equatable {
    case one = "1x"
    case two = "2x"
    case three = "3x"
}

public enum ImageRenderingMode: String, CaseIterable {
    case `default`
    case original
    case template
}
