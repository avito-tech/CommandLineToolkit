import FileSystem
import Foundation
import PathLib

public class FakeFilePropertiesContainer: FilePropertiesContainer {
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
    
    public var fileSize = 0
    public func size() throws -> Int { fileSize }
}
