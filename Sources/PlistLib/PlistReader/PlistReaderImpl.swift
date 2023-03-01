import FileSystem
import PathLib

public final class PlistReaderImpl: PlistReader {
    private let fileReader: FileReader
    
    public init(fileReader: FileReader) {
        self.fileReader = fileReader
    }
    
    public func readPlist(path: AbsolutePath) throws -> Plist {
        try Plist.create(
            fromData: fileReader.contents(filePath: path)
        )
    }
}
