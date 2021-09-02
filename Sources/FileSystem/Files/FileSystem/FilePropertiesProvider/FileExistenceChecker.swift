import PathLib

public protocol FileExistenceChecker {
    func existence(path: AbsolutePath) -> FileExistence
}

extension FileExistenceChecker {
    public func exists(
        path: AbsolutePath
    ) -> Bool {
        return existence(path: path).exists
    }
}
