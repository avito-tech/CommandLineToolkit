public protocol EnvironmentProvider: AnyObject {
    var environment: [String: String] { get }
    
    func get<Value>(_ key: EnvironmentKey<Value>) throws -> Value?
}

extension EnvironmentProvider {
    public func get<Value>(_ key: EnvironmentKey<Value>) throws -> Value? {
        guard let value = environment[key.key] else {
            return nil
        }
        
        return try key.conversion.apply(value)
    }
    
    public func get<Value>(_ key: EnvironmentKey<Value>, default value: @autoclosure () -> Value) throws -> Value {
        return try get(key) ?? value()
    }
}
