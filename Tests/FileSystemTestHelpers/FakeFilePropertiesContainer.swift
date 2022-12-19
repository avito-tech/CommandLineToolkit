import FileSystem
import Foundation
import PathLib
import Types

open class FakeFilePropertiesContainer: FilePropertiesContainer {
    public var pathExists: Bool
    
    public init(
        pathExists: Bool = true
    ) {
        self.pathExists = pathExists
    }
    
    public var modificationDate: ThrowingPropertyOf<Date> = FakeThrowingProperty(
        value: Date(timeIntervalSince1970: 500)
    )
    
    public var isExecutable = false
    public var isDirectory = false
    public var isRegularFile = true
    public var isHidden = false
    public var fileSize = 0
    public var totalFileAllocatedSize = 0
    
    public func exists() -> Bool { pathExists }
    
    public var permissions: ThrowingPropertyOf<Int16> = FakeThrowingProperty(
        value: 0o755
    )
    
    public var userId: ThrowingPropertyOf<Int> = FakeThrowingProperty(
        value: 0
    )
    
    public var isSymbolicLink = false
    
    public var isBrokenSymbolicLink = false
    
    public var isSymbolicLinkToDirectory = false
    
    public var isSymbolicLinkToFile = false
    
    public var symbolicLinkPath: AbsolutePath?
    
    public var existence: FileExistence {
        if pathExists {
            if isDirectory {
                return .isDirectory
            } else {
                return .isFile
            }
        } else {
            return .doesntExist
        }
    }
}
