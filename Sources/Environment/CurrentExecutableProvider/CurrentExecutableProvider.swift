import PathLib

public protocol CurrentExecutableProvider {
    func currentExecutablePath() throws -> AbsolutePath
}
