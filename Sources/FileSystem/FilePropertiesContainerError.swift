import Foundation
import PathLib

public enum FilePropertiesContainerError: Error, CustomStringConvertible {
    case emptyValue(AbsolutePath, URLResourceKey)
    case emptyFileAttributeValue(AbsolutePath, FileAttributeKey)
    
    public var description: String {
        switch self {
        case let .emptyValue(path, property):
            return "File at path \(path) does not have a value for property \(property)"
        case let .emptyFileAttributeValue(path, key):
            return "File at path \(path) does not have a value for key \(key)"
        }
    }
}
