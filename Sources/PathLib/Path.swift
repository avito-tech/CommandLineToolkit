import Foundation

public protocol Path: CustomStringConvertible {
    init<S: StringProtocol>(components: [S])
    
    var components: [String] { get }
    var pathString: String { get }
}

extension Path {
    public var description: String {
        return pathString
    }
    
    public var asString: String {
        return pathString
    }
}
