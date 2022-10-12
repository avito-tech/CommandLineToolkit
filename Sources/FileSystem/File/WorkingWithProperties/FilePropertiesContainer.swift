import Foundation
import PathLib

public protocol FilePropertiesContainer {
    func existence() -> FileExistence
    func isExecutable() throws -> Bool
    func isDirectory() throws -> Bool
    func isRegularFile() throws -> Bool
    func isHidden() throws -> Bool
    
    func isSymbolicLink() throws -> Bool
    func isBrokenSymbolicLink() throws -> Bool
    func isSymbolicLinkToDirectory() throws -> Bool
    func isSymbolicLinkToFile() throws -> Bool
    func symbolicLinkPath() throws -> AbsolutePath?
    
    func modificationDate() throws -> Date
    func set(modificationDate: Date) throws
    
    func permissions() throws -> Int16
    func set(permissions: Int16) throws
    
    func fileSize() throws -> Int
    func totalFileAllocatedSize() throws -> Int
}

extension FilePropertiesContainer {
    public func touch() throws {
        try set(modificationDate: Date())
    }
    
    public func exists(type: FileExistenceCheckType = .any) -> Bool {
        switch type {
        case .any:
            return existence().exists
        case .directory:
            return existence().isDirectory
        case .file:
            return existence().isFile
        }
    }
}
