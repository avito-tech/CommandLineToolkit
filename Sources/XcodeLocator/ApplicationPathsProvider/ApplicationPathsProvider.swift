import PathLib

public protocol ApplicationPathsProvider {
    func applicationPaths() throws -> [AbsolutePath]
}
