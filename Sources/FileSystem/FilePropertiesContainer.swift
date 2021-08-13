import Foundation
import PathLib

public protocol FilePropertiesContainer {
    func exists() -> Bool
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
    
    func size() throws -> Int
}

public extension FilePropertiesContainer {
    func touch() throws { try set(modificationDate: Date()) }
}
