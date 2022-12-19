import Foundation
import PathLib

public enum FilePropertiesContainerError: Error, CustomStringConvertible {
    case emptyValue(
        path: AbsolutePath,
        key: URLResourceKey
    )
    case emptyFileAttributeValue(
        path: AbsolutePath,
        key: FileAttributeKey
    )
    case mismatchingFileAttributeValueType(
        path: AbsolutePath,
        key: FileAttributeKey,
        value: Any,
        expectedType: Any.Type
    )
    case unrecognizedSymbolicLinkValue(
        path: AbsolutePath,
        symbolicLinkValue: String
    )
    
    public var description: String {
        switch self {
        case let .emptyValue(path, property):
            return "File at path \(path) does not have a value for property \(property)"
        case let .emptyFileAttributeValue(path, key):
            return "File at path \(path) does not have an attribure for key \(key)"
        case let .mismatchingFileAttributeValueType(path, key, value, expectedType):
            return "File at path \(path) has value for key \(key) of type \(type(of: value)), expected type: \(expectedType)"
        case let .unrecognizedSymbolicLinkValue(path, symbolicLinkValue):
            return "Symbolic link at path \(path) with value \(symbolicLinkValue) is not a RelativePath or AbsolutePath"
        }
    }
}
