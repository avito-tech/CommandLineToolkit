import ImagesInterfaces

public final class ImageSetGeneratorMock: ImageSetGenerator {
    
    public struct Input: Equatable {
        public let inputSource: ImageSource
        public let inputSelectedCategory: KnownImageCategory
        public let inputSelectedRenderingMode: ImageRenderingMode
        public let inputPreserveVectorRepresentation: Bool
        public let inputKnownImageCategories: [KnownImageCategory]
        public let inputTargetScope: ImageTargetScope
        
        public init(
            inputSource: ImageSource,
            inputSelectedCategory: KnownImageCategory,
            inputSelectedRenderingMode: ImageRenderingMode,
            inputPreserveVectorRepresentation: Bool,
            inputKnownImageCategories: [KnownImageCategory],
            inputTargetScope: ImageTargetScope
        ) {
            self.inputSource = inputSource
            self.inputSelectedCategory = inputSelectedCategory
            self.inputSelectedRenderingMode = inputSelectedRenderingMode
            self.inputPreserveVectorRepresentation = inputPreserveVectorRepresentation
            self.inputKnownImageCategories = inputKnownImageCategories
            self.inputTargetScope = inputTargetScope
        }
    }
    public var input: Input?
    
    public var shouldThrowException: Bool = false
    public var exceptionMessage: String = "ImageSetGeneratorMock exception"
    
    public init() {}
    
    public func generateAssets(
        from source: ImageSource,
        selectedCategory: KnownImageCategory,
        selectedRenderingMode: ImageRenderingMode,
        preserveVectorRepresentation: Bool,
        knownImageCategories: KnownImageCategories,
        targetScope: ImageTargetScope
    ) throws {
        if shouldThrowException {
            throw ImageError(exceptionMessage)
        }
        input = Input(
            inputSource: source,
            inputSelectedCategory: selectedCategory,
            inputSelectedRenderingMode: selectedRenderingMode,
            inputPreserveVectorRepresentation: preserveVectorRepresentation,
            inputKnownImageCategories: knownImageCategories.all,
            inputTargetScope: targetScope
        )
    }
}
