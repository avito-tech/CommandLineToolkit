import PathLib
import Foundation

public protocol FileCreator {
    func createFile(path: AbsolutePath, data: Data?) throws
}
