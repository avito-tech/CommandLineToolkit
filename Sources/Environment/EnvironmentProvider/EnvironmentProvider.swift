public protocol EnvironmentProvider: AnyObject {
    var environment: [String: String] { get }
}
