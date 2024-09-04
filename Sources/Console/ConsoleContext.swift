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
    
    func withUpdated<Value>(key: WritableKeyPath<ConsoleContext, Value>, value: Value) -> ConsoleContext {
        var newContext = self
        newContext[keyPath: key] = value
        return newContext
    }
}

extension TaskLocal where Value == ConsoleContext {
    func withUpdated<R, ContextValue>(
        key: WritableKeyPath<ConsoleContext, ContextValue>,
        value: ContextValue,
        operation: () throws -> R
    ) rethrows -> R {
        try self.withValue(wrappedValue.withUpdated(key: key, value: value), operation: operation)
    }
    
    func withUpdated<R, ContextValue>(
        key: WritableKeyPath<ConsoleContext, ContextValue>,
        value: ContextValue,
        operation: () async throws -> R
    ) async rethrows -> R {
        try await self.withValue(wrappedValue.withUpdated(key: key, value: value), operation: operation)
    }
}
