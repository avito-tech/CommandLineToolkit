import Foundation
import PathLib
import Types

public protocol FilePropertiesContainer {
    // Non-modifiable
    var existence: FileExistence { get }
    
    var isExecutable: Bool { get throws } // note: relies not just on file permissions, but also on current user
    var isDirectory: Bool { get throws }
    var isRegularFile: Bool { get throws }
    var isHidden: Bool { get throws } // I think, it's theoretically modifiable, but not for all file systems
    
    var isSymbolicLink: Bool { get throws }
    var isBrokenSymbolicLink: Bool { get throws }
    var isSymbolicLinkToDirectory: Bool { get throws }
    var isSymbolicLinkToFile: Bool { get throws }
    var symbolicLinkPath: AbsolutePath? { get throws }
    
    var fileSize: Int { get throws }
    var totalFileAllocatedSize: Int { get throws }
    
    // Modifiable
    var modificationDate: ThrowingPropertyOf<Date> { get }
    var permissions: ThrowingPropertyOf<Int16> { get }
    var userId: ThrowingPropertyOf<Int> { get }
}

extension FilePropertiesContainer {
    public func touch() throws {
        try modificationDate.set(Date())
    }
    
    public func exists(type: FileExistenceCheckType = .any) -> Bool {
        switch type {
        case .any:
            return existence.exists
        case .directory:
            return existence.isDirectory
        case .file:
            return existence.isFile
        }
    }
}
