import Foundation

extension Dictionary {
    @inlinable
    public func mapKeys<R: Hashable>(
        keyMapping: (Key) throws -> R
    ) rethrows -> [R: Value] {
        .init(uniqueKeysWithValues: try map {
            (try keyMapping($0.key), $0.value)
        })
    }
    
    @inlinable
    public func mapValuesWithKeys<T>(
        transform: (Key, Value) throws -> T
    ) rethrows -> [Key: T] {
        .init(uniqueKeysWithValues: try map {
            try ($0.key, transform($0.key, $0.value))
        })
    }
}
