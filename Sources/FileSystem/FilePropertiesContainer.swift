import Foundation

public protocol FilePropertiesContainer {
    func exists() -> Bool
    func isExecutable() throws -> Bool
    func isDirectory() throws -> Bool
    func isRegularFile() throws -> Bool
    
    func modificationDate() throws -> Date
    func set(modificationDate: Date) throws
    
    func permissions() throws -> Int16
    func set(permissions: Int16) throws
    
    func size() throws -> Int
}

public extension FilePropertiesContainer {
    func touch() throws { try set(modificationDate: Date()) }
}
