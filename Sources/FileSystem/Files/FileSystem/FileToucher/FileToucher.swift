import PathLib

public protocol FileToucher {
    func touch(path: AbsolutePath) throws
}
