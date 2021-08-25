public final class FileExistence {
    public let exists: Bool
    public let isFile: Bool
    public let isDirectory: Bool
    
    public init(exists: Bool, isFile: Bool, isDirectory: Bool) {
        self.exists = exists
        self.isFile = isFile
        self.isDirectory = isDirectory
    }
    
    public static let isFile = FileExistence(
        exists: true,
        isFile: true,
        isDirectory: false
    )
    
    public static let isDirectory = FileExistence(
        exists: true,
        isFile: false,
        isDirectory: true
    )
    
    public static let doesntExist = FileExistence(
        exists: false,
        isFile: false,
        isDirectory: false
    )
}
