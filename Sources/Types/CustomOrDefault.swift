/// A container of a value or a mark that default value should be used
///
/// Traditionally in Swift people use Optional, where `nil` is treated as a default value.
/// Optionak has exactly same implementation as this enum, but semantics are not clear in a given code that uses Optional for that.
///
/// What does this code do?
///
/// ```
/// select(thingToSelect: nil)
/// ```
///
/// Selects nothing?
///
/// This is more readable:
///
/// ```
/// select(thingToSelect: .default)
/// ```
///
public enum CustomOrDefault<T> {
    case custom(T)
    case `default`
    
    public func value(
        defaultValue: T
    ) -> T {
        switch self {
        case .custom(let value):
            return value
        case .default:
            return defaultValue
        }
    }
    
    public init(customValue: T?) {
        switch customValue {
        case .none:
            self = .default
        case .some(let wrapped):
            self = .custom(wrapped)
        }
    }
}
