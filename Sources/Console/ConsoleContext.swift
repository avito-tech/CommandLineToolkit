import Foundation

protocol ConsoleContextKey {
    associatedtype Value

    static var defaultValue: Value { get }
}

struct ConsoleContext {
    @TaskLocal
    static var current: ConsoleContext = .init()

    private var storage: [ObjectIdentifier: Any] = [:]

    subscript <Key: ConsoleContextKey>(_ key: Key.Type) -> Key.Value {
        get { storage[ObjectIdentifier(key)] as? Key.Value ?? key.defaultValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }

    static func current<Value>(with key: WritableKeyPath<ConsoleContext, Value>, value: Value) -> ConsoleContext {
        var newContext = current
        newContext[keyPath: key] = value
        return newContext
    }
}
