import Foundation
import FileSystem
import PathLib

open class FakeFileReader: FileReader {
    public var provider: (AbsolutePath) throws -> Data
    
    public init(
        provider: @escaping (AbsolutePath) throws -> Data = { _ in
            Data()
        }
    ) {
        self.provider = provider
    }
    
    public func contents(
        filePath: AbsolutePath
    ) throws -> Data {
        try provider(filePath)
    }
}
