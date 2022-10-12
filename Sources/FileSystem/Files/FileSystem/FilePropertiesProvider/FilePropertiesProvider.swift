import PathLib
import Foundation

public protocol FilePropertiesProvider: FileExistenceChecker {
    func properties(forFileAtPath: AbsolutePath) -> FilePropertiesContainer
}

extension FilePropertiesProvider {
    public func existence(path: AbsolutePath) -> FileExistence {
        properties(forFileAtPath: path).existence()
    }
    
    public func isExecutable(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isExecutable()
    }
    
    public func isDirectory(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isDirectory()
    }
    
    public func isRegularFile(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isRegularFile()
    }
    
    public func isHidden(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isHidden()
    }
    
    public func isSymbolicLink(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isSymbolicLink()
    }
    
    public func isBrokenSymbolicLink(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isBrokenSymbolicLink()
    }
    
    public func isSymbolicLinkToDirectory(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isSymbolicLinkToDirectory()
    }
    
    public func isSymbolicLinkToFile(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isSymbolicLinkToFile()
    }
    
    public func symbolicLinkPath(for path: AbsolutePath) throws -> AbsolutePath? {
        try properties(forFileAtPath: path).symbolicLinkPath()
    }
    
    // MARK: mtime
    
    public func modificationDate(for path: AbsolutePath) throws -> Date {
        try properties(forFileAtPath: path).modificationDate()
    }
    
    public func set(modificationDate: Date, for path: AbsolutePath) throws {
        try properties(forFileAtPath: path).set(modificationDate: modificationDate)
    }
    
    // MARK: Permissions
    
    public func permissions(for path: AbsolutePath) throws -> Int16 {
        try properties(forFileAtPath: path).permissions()
    }
    
    public func set(permissions: Int16, for path: AbsolutePath) throws {
        try properties(forFileAtPath: path).set(permissions: permissions)
    }
    
    // MARK: -
    
    public func size(for path: AbsolutePath) throws -> Int {
        try properties(forFileAtPath: path).fileSize()
    }
}
