import PathLib

public protocol RealpathProvider {
    func realpath(path: AbsolutePath) throws -> AbsolutePath
}
