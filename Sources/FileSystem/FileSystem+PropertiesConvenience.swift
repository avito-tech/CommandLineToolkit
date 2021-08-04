import Foundation
import PathLib

public extension FileSystem {
    func exists(path: AbsolutePath) -> Bool {
        properties(forFileAtPath: path).exists()
    }
    
    func isExecutable(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isExecutable()
    }
    
    func isDirectory(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isDirectory()
    }
    
    func isRegularFile(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isRegularFile()
    }
    
    func isHidden(path: AbsolutePath) throws -> Bool {
        try properties(forFileAtPath: path).isHidden()
    }
    
    // MARK: mtime
    
    func modificationDate(for path: AbsolutePath) throws -> Date {
        try properties(forFileAtPath: path).modificationDate()
    }
    
    func set(modificationDate: Date, for path: AbsolutePath) throws {
        try properties(forFileAtPath: path).set(modificationDate: modificationDate)
    }
    
    // MARK: Permissions
    
    func permissions(for path: AbsolutePath) throws -> Int16 {
        try properties(forFileAtPath: path).permissions()
    }
    
    func set(permissions: Int16, for path: AbsolutePath) throws {
        try properties(forFileAtPath: path).set(permissions: permissions)
    }
    
    // MARK: -
    
    func size(for path: AbsolutePath) throws -> Int {
        try properties(forFileAtPath: path).size()
    }
    
    func touch(path: AbsolutePath) throws {
        if exists(path: path) {
            try properties(forFileAtPath: path).touch()
        } else {
            try createFile(atPath: path, data: nil)
        }
    }
}
