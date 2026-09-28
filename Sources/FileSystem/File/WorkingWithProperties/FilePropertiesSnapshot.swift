import Foundation

/// Metadata read together, following symbolic links to their targets.
public struct FilePropertiesSnapshot {
    public enum Kind {
        case regularFile
        case directory
        case other
    }

    public let kind: Kind
    public let modificationDate: Date
    public let size: Int

    public init(kind: Kind, modificationDate: Date, size: Int) {
        self.kind = kind
        self.modificationDate = modificationDate
        self.size = size
    }
}
