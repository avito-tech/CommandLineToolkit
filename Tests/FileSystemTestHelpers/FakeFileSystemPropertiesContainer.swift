import FileSystem
import Foundation
import PathLib

open class FakeFileSystemPropertiesContainer: FileSystemPropertiesContainer {
    public init() {}
    
    public var systemFreeSizeValue: Int64 = 42
    public func systemFreeSize() throws -> Int64 {
        systemFreeSizeValue
    }
}
