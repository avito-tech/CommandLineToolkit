import CLTExtensions
#if canImport(Darwin)
import Darwin
#endif
#if canImport(Glibc)
import Glibc
#endif
import Foundation
import PathLib

public final class TemporaryFolder {
    public let absolutePath: AbsolutePath
    private let deleteOnDealloc: Bool
    
    public init(
        containerPath: AbsolutePath? = nil,
        prefix: String = "TemporaryFolder",
        deleteOnDealloc: Bool = true
    ) throws {
        if let containerPath = containerPath {
            try FileManager.default.createDirectory(atPath: containerPath)
        }
        let containerPath = containerPath ?? AbsolutePath(NSTemporaryDirectory())
        let pathTemplate = containerPath.appending("\(prefix).XXXXXX")
        var templateBytes = [UInt8](pathTemplate.pathString.utf8).map { Int8($0) } + [Int8(0)]
        if mkdtemp(&templateBytes) == nil {
            throw ErrnoError.failedToCreateTemporaryFolder(pathTemplate, code: errno)
        }
        
        let resultingPath = String(cString: templateBytes)
        let urlValues = try URL(fileURLWithPath: resultingPath).resourceValues(forKeys: [.canonicalPathKey])
        guard let canonicalPath = urlValues.canonicalPath else {
            throw UnknownCanonicalPath(path: resultingPath)
        }
        
        self.absolutePath = AbsolutePath(canonicalPath)
        self.deleteOnDealloc = deleteOnDealloc
    }
    
    deinit {
        if deleteOnDealloc {
            try? FileManager.default.removeItem(atPath: absolutePath.pathString)
        } else {
            rmdir(absolutePath.pathString)
        }
    }
    
    public func pathWith(components: [String]) -> AbsolutePath {
        return absolutePath.appending(components: components)
    }
    
    @discardableResult
    public func createDirectory(components: [String], attributes: [FileAttributeKey: Any]? = nil) throws -> AbsolutePath {
        let path = pathWith(components: components)
        try FileManager.default.createDirectory(atPath: path, attributes: attributes)
        return path
    }
    
    @discardableResult
    public func createFile(components: [String] = [], filename: String, contents: Data? = nil, attributes: [FileAttributeKey: Any]? = nil) throws -> AbsolutePath {
        let container = try createDirectory(components: components)
        let path = container.appending(filename)
        FileManager.default.createFile(atPath: path.pathString, contents: contents, attributes: attributes)
        return path
    }
    
    @discardableResult
    public func createFile(components: [String] = [], filename: String, contents: String, attributes: [FileAttributeKey: Any]? = nil) throws -> AbsolutePath {
        return try createFile(components: components, filename: filename, contents: contents.dataUsingUtf8(), attributes: attributes)
    }
    
    public func createSymbolicLink(at path: RelativePath, destination: Path) throws -> AbsolutePath {
        let symbolicLinkPath = pathWith(components: path.components)
        try FileManager.default.createSymbolicLink(
            atPath: symbolicLinkPath.pathString,
            withDestinationPath: destination.pathString
        )
        return symbolicLinkPath
    }
    
    public static func == (left: TemporaryFolder, right: TemporaryFolder) -> Bool {
        return left.absolutePath == right.absolutePath
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(absolutePath)
    }
}
