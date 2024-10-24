import PathLib
import Foundation

public final class FileAppenderImpl: FileAppender {
    public init() {}

    public func appendToFile(path: AbsolutePath, data: Data) throws {
        if let fileHandle = FileHandle(forWritingAtPath: path.pathString) {
            defer { fileHandle.closeFile() }
            try fileHandle.seekToEnd()
            fileHandle.write(data)
        } else {
            try data.write(to: path.fileUrl, options: .atomic)
        }
    }
}
