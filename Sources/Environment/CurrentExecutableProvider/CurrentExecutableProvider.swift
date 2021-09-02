public protocol CurrentExecutableProvider {
    func currentExecutablePath() throws -> String
}
