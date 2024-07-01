import Foundation
import PathLib

public enum IncludeLangOption: String {
    case swift = "swift"
    case objc = "objective-c"
    case cCPlusPlusHeader = "h"
}

public protocol Cloc {
    func countLinesOfCode(
        sourceFiles: [AbsolutePath],
        includeLangOptions: Set<IncludeLangOption>
    ) throws -> Int
}

public extension Cloc {
    func countLinesOfCode(
        sourceFiles: [AbsolutePath]
    ) throws -> Int {
        try countLinesOfCode(sourceFiles: sourceFiles, includeLangOptions: [.swift])
    }
}
