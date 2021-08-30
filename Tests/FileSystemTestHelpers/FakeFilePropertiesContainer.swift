import FileSystem
import Foundation
import PathLib

open class FakeFilePropertiesContainer: FilePropertiesContainer {
    public init(
        pathExists: Bool = true
    ) {
        self.pathExists = pathExists
    }
    
    public var mdate = Date(timeIntervalSince1970: 500)
    public func modificationDate() throws -> Date { mdate }
    public func set(modificationDate: Date) throws { mdate = modificationDate }
    
    public var executable = false
    public func isExecutable() throws -> Bool { executable }
    
    public var pathExists: Bool
    public func exists() -> Bool { pathExists }
    
    public var posixPermissions: Int16 = 0o755
    public func permissions() throws -> Int16 { posixPermissions }
    public func set(permissions: Int16) throws { posixPermissions = permissions }
    
    public var directory = false
    public func isDirectory() throws -> Bool { directory }
    
    public var regularFile = true
    public func isRegularFile() throws -> Bool { regularFile }
    
    public var hidden = false
    public func isHidden() throws -> Bool { hidden }
    
    public var fileSize = 0
    public func size() throws -> Int { fileSize }
    
    public var symbolicLink = false
    public func isSymbolicLink() throws -> Bool { symbolicLink }
    
    public var brokenSymbolicLink = false
    public func isBrokenSymbolicLink() throws -> Bool { brokenSymbolicLink }
    
    public var symbolicLinkToDirectory = false
    public func isSymbolicLinkToDirectory() throws -> Bool { symbolicLinkToDirectory }
    
    public var symbolicLinkToFile = false
    public func isSymbolicLinkToFile() throws -> Bool { symbolicLinkToFile }
    
    public var symbolicLinkPathValue: AbsolutePath?
    public func symbolicLinkPath() throws -> AbsolutePath? { symbolicLinkPathValue }
    
    public func existence() -> FileExistence {
        if pathExists {
            if directory {
                return .isDirectory
            } else {
                return .isFile
            }
        } else {
            return .doesntExist
        }
    }
}
