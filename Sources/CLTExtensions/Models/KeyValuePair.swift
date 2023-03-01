public final class KeyValuePair<Key: Hashable, Value> {
    public let key: Key
    public let value: Value
    
    public init(
        key: Key,
        value: Value
    ) {
        self.key = key
        self.value = value
    }
}
