import Foundation

public protocol FilePropertiesContainer {
    func modificationDate() throws -> Date
    func set(modificationDate: Date) throws
    
    func isExecutable() throws -> Bool
    func permissions() throws -> Int16
    func set(permissions: Int16) throws
    func exists() -> Bool
    func isDirectory() throws -> Bool
    func isRegularFile() throws -> Bool
    func size() throws -> Int
}

public extension FilePropertiesContainer {
    func touch() throws { try set(modificationDate: Date()) }
}
