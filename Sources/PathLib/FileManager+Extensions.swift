import Foundation

public extension FileManager {
    func createDirectory(
        atPath path: AbsolutePath,
        withIntermediateDirectories: Bool = true,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        if !directoryExists(path: path) {
            try createDirectory(
                atPath: path.pathString,
                withIntermediateDirectories: withIntermediateDirectories,
                attributes: attributes
            )
        }
    }
    
    var currentAbsolutePath: AbsolutePath {
        return AbsolutePath(currentDirectoryPath)
    }
    
    func directoryExists(path: AbsolutePath) -> Bool {
        var isDirectory: ObjCBool = false
        let fileExists = fileExists(atPath: path.pathString, isDirectory: &isDirectory)
        
        return fileExists && isDirectory.boolValue
    }
}
