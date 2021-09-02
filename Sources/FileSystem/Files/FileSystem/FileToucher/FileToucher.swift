import PathLib

// TODO: Add `ensureDirectoryExists` parameter.
// Note that `FileCreator` in `FileToucherImpl` duplicates `DataWriter`
// and missed `ensureDirectoryExists` too (`DataWriter` doesn't)
// This should be addressed first.
public protocol FileToucher {
    func touch(path: AbsolutePath) throws
}
