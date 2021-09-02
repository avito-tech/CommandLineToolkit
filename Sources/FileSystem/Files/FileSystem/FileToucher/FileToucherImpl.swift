import PathLib

public final class FileToucherImpl: FileToucher {
    private let filePropertiesProvider: FilePropertiesProvider
    private let fileCreator: FileCreator
    
    public init(
        filePropertiesProvider: FilePropertiesProvider,
        fileCreator: FileCreator
    ) {
        self.filePropertiesProvider = filePropertiesProvider
        self.fileCreator = fileCreator
    }
    
    public func touch(path: AbsolutePath) throws {
        if filePropertiesProvider.existence(path: path).exists {
            try filePropertiesProvider.properties(forFileAtPath: path).touch()
        } else {
            try fileCreator.createFile(path: path, data: nil)
        }
    }
}
