import FileSystem
import PathLib

public protocol PlistReader {
    func readPlist(path: AbsolutePath) throws -> Plist
}
