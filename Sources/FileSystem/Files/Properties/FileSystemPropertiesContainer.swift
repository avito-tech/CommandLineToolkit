import Foundation

public protocol FileSystemPropertiesContainer {
    func systemFreeSize() throws -> Int64
}
