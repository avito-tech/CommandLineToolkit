import Foundation

public struct FailedCast<T>: Error, CustomStringConvertible {
    public let value: Any?
    
    public var description: String {
        "Can't cast value \(value ?? "nil") of type \(type(of: value)) to type \(T.self)"
    }
}

public func cast<T>(
    value: Any,
    to targetType: T.Type
) throws -> T {
    guard let castedValue = value as? T else {
        throw FailedCast<T>(value: value)
    }
    return castedValue
}

public func cast<T, V>(
    optionalValue: V?,
    to targetType: T.Type
) throws -> T {
    if let value = optionalValue {
        return try cast(value: value, to: T.self)
    }
    throw FailedCast<T>(value: nil)
}

public func cast<T>(value: Any) throws -> T {
    return try cast(value: value, to: T.self)
}
