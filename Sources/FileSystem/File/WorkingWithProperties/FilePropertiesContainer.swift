import Foundation
import PathLib
import Types

public protocol FilePropertiesContainer {
    func snapshot() throws -> FilePropertiesSnapshot
    func snapshot(followSymbolicLinks: Bool) throws -> FilePropertiesSnapshot

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
    public func snapshot(followSymbolicLinks: Bool) throws -> FilePropertiesSnapshot {
        if !followSymbolicLinks, try isSymbolicLink {
            return try FilePropertiesSnapshot(kind: .symbolicLink, modificationDate: modificationDate.get(), size: fileSize)
        }
        return try snapshot()
    }

    public func snapshot() throws -> FilePropertiesSnapshot {
        let kind: FilePropertiesSnapshot.Kind
        if try isRegularFile || isSymbolicLinkToFile {
            kind = .regularFile
        } else if try isDirectory || isSymbolicLinkToDirectory {
            kind = .directory
        } else if try isBrokenSymbolicLink {
            throw CocoaError(.fileReadNoSuchFile)
        } else {
            kind = .other
        }
        return try FilePropertiesSnapshot(kind: kind, modificationDate: modificationDate.get(), size: fileSize)
    }

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
