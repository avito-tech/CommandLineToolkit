import Dispatch
import Foundation

@propertyWrapper
public final class AtomicValue<T> {
    private var value: T
    private let lock = NSRecursiveLock()

    public init(_ value: T) {
        self.value = value
    }
    
    public init(wrappedValue: T) {
        self.value = wrappedValue
    }
    
    public var wrappedValue: T {
        get { currentValue() }
        set { set(newValue) }
        _modify {
            lock.lock()
            defer { lock.unlock() }
            yield &value
        }
    }

    public var projectedValue: AtomicValue {
        return self
    }

    @discardableResult
    public func withExclusiveAccess<R>(work: (inout T) throws -> R) rethrows -> R {
        lock.lock()
        defer { lock.unlock() }
        return try work(&value)
    }
    
    public func currentValue() -> T {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
    
    public func set(_ newValue: T) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}
