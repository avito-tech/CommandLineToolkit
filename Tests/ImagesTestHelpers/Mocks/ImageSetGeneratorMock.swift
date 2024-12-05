import ImagesInterfaces

public final class ImageSetGeneratorMock: ImageSetGenerator {
    
    public struct Input: Equatable {
        public let inputSource: ImageSource
        public let inputSelectedCategory: KnownImageCategory
        public let inputSelectedRenderingMode: ImageRenderingMode
        public let inputIsVector: Bool
        public let inputKnownImageCategories: [KnownImageCategory]
        
        public init(inputSource: ImageSource, inputSelectedCategory: KnownImageCategory, inputSelectedRenderingMode: ImageRenderingMode, inputIsVector: Bool, inputKnownImageCategories: [KnownImageCategory]) {
            self.inputSource = inputSource
            self.inputSelectedCategory = inputSelectedCategory
            self.inputSelectedRenderingMode = inputSelectedRenderingMode
            self.inputIsVector = inputIsVector
            self.inputKnownImageCategories = inputKnownImageCategories
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
        isVector: Bool,
        knownImageCategories: KnownImageCategories
    ) throws {
        if shouldThrowException {
            throw ImageError(exceptionMessage)
        }
        input = Input(
            inputSource: source,
            inputSelectedCategory: selectedCategory,
            inputSelectedRenderingMode: selectedRenderingMode,
            inputIsVector: isVector,
            inputKnownImageCategories: knownImageCategories.all
        )
    }
}
