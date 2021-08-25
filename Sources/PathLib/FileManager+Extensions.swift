import Foundation

public extension FileManager {
    func createDirectory(
        atPath path: AbsolutePath,
        withIntermediateDirectories: Bool = true
    ) throws {
        if !directoryExists(path: path) {
            try createDirectory(
                atPath: path.pathString,
                withIntermediateDirectories: withIntermediateDirectories
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
