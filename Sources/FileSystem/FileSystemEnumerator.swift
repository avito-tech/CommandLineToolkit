import Foundation
import PathLib

public protocol FileSystemEnumerator {
    func each(iterator: (AbsolutePath) throws -> ()) throws
}

public extension FileSystemEnumerator {
    func allPaths() throws -> [AbsolutePath] {
        var paths = [AbsolutePath]()
        try each { path in
            paths.append(path)
        }
        return paths
    }
}
