import ImagesInterfaces
import PathLib

public final class ImageFactoryGeneratorMock: ImageFactoryGenerator {
    
    public var isCalled = false
    
    public init() {}
    
    public func generateFactoryFile() throws {
        isCalled = true
    }
}
