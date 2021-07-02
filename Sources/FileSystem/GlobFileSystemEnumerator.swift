import Foundation
import Glob
import PathLib

public final class GlobFileSystemEnumerator: FileSystemEnumerator {
    private let pattern: GlobPattern
    
    public init(
        pattern: GlobPattern
    ) {
        self.pattern = pattern
    }
 
    public func each(iterator: (AbsolutePath) throws -> ()) throws {
        let glob = Glob(
            pattern: pattern.value,
            behavior: .BashV4
        )
        for path in glob {
            try iterator(AbsolutePath(path))
        }
    }
}
