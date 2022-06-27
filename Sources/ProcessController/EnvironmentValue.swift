import Foundation

public protocol EnvironmentValue: CustomStringConvertible {
    var value: String { get }
}

extension String: EnvironmentValue {
    public var value: String { self }
}

extension Int: EnvironmentValue {
    public var value: String { "\(self)" }
}

public struct SecureEnvironmentValue: EnvironmentValue {
    private let environmentValue: EnvironmentValue
    
    public init(environmentValue: EnvironmentValue) {
        self.environmentValue = environmentValue
    }
    
    public var value: String {
        environmentValue.value
    }
    
    public var description: String {
        "<secure value>"
    }
}

extension EnvironmentValue {
    public var secured: EnvironmentValue {
        return SecureEnvironmentValue(environmentValue: self)
    }
}
