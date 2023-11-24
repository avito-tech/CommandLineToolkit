import Foundation
import PathLib

public protocol Cloc {
    func countLinesOfCode(
        sourceFiles: [AbsolutePath]
    ) throws -> Int
}
