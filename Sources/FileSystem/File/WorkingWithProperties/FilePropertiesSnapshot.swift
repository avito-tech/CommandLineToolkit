import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Metadata read together in a single filesystem request.
public struct FilePropertiesSnapshot: Sendable {
    public enum Kind: Sendable {
        case regularFile
        case directory
        case symbolicLink
        case other
    }

    public let kind: Kind
    public let modificationDate: Date
    public let size: Int
    /// Exact UNIX timestamp when supplied by the filesystem (no Date rounding).
    public let modificationTimeNanoseconds: UInt64?

    public init(kind: Kind, modificationDate: Date, size: Int, modificationTimeNanoseconds: UInt64? = nil) {
        self.kind = kind
        self.modificationDate = modificationDate
        self.size = size
        self.modificationTimeNanoseconds = modificationTimeNanoseconds
    }
}

extension FilePropertiesSnapshot {
    static func read(path: String, followSymbolicLinks: Bool) throws -> Self {
        var info = stat()
        let result = followSymbolicLinks ? stat(path, &info) : lstat(path, &info)
        guard result == 0 else {
            throw fileSystemError(operation: followSymbolicLinks ? "stat" : "lstat", path: path)
        }
        let kind: FilePropertiesSnapshot.Kind
        switch info.st_mode & mode_t(S_IFMT) {
        case mode_t(S_IFREG):
            kind = .regularFile
        case mode_t(S_IFDIR):
            kind = .directory
        case mode_t(S_IFLNK):
            kind = .symbolicLink
        default:
            kind = .other
        }
        #if canImport(Darwin)
        let modified = info.st_mtimespec
        #else
        let modified = info.st_mtim
        #endif
        return FilePropertiesSnapshot(
            kind: kind,
            modificationDate: Date(timeIntervalSince1970: Double(modified.tv_sec) + Double(modified.tv_nsec) / 1_000_000_000),
            size: Int(info.st_size),
            modificationTimeNanoseconds: UInt64(exactly: modified.tv_sec).flatMap { seconds in
                let (base, overflow) = seconds.multipliedReportingOverflow(by: 1_000_000_000)
                let (value, additionOverflow) = base.addingReportingOverflow(UInt64(modified.tv_nsec))
                return overflow || additionOverflow ? nil : value
            }
        )
    }
}
