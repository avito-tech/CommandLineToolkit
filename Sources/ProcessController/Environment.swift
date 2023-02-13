import Foundation
import Environment

public struct Environment: ExpressibleByDictionaryLiteral, CustomStringConvertible {
    public var values: [String: EnvironmentValue]
    
    public init(_ values: [String: EnvironmentValue]) {
        self.values = values
    }
    
    public static var current: Environment {
        Environment(ProcessInfo.processInfo.environment)
    }
    
    public func merging(with values: [String: EnvironmentValue]) -> Environment {
        var result = self.values
        result.merge(values) { _, new -> EnvironmentValue in new }
        return Environment(result)
    }
    
    public var description: String {
        values.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
    }
    
    public var asStringDictionary: [String: String] {
        values.mapValues { environmentValue in
            environmentValue.value
        }
    }
    
    // MARK: - ExpressibleByDictionaryLiteral
    
    public typealias Key = String
    public typealias Value = EnvironmentValue
    public init(dictionaryLiteral elements: (String, EnvironmentValue)...) {
        var values = [String: EnvironmentValue]()
        for element in elements {
            values[element.0] = element.1
        }
        self.values = values
    }
}

extension Environment {
    public func get<Value>(_ key: EnvironmentKey<Value>) throws -> Value? {
        guard let value = values[key.key] else {
            return nil
        }

        return try key.conversion.apply(value.value)
    }

    public mutating func set<Value>(
        _ key: EnvironmentKey<Value>,
        to value: Value
    ) throws {
        values[key.key] = try key.conversion.unapply(value)
    }
}
