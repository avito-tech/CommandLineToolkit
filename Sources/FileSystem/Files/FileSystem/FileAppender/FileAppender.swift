import PathLib
import Foundation

public protocol FileAppender {
    func appendToFile(path: AbsolutePath, data: Data) throws
}
