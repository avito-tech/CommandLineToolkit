import Foundation
import PathLib

public protocol RepoRootProvider {
    func repoRoot() throws -> AbsolutePath
}
