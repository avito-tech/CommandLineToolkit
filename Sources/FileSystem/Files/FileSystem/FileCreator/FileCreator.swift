import PathLib
import Foundation

// TODO: Remove code duplication with `DataWriter`.
public protocol FileCreator {
    func createFile(
        path: AbsolutePath,
        data: Data?
    ) throws
}
