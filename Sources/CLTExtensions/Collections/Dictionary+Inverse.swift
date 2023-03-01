extension Dictionary where Value: Hashable {
    public func inverseKeysAndValuesWithNonUniqueKeys() -> [Value: [Key]] {
        map { key, value in
            KeyValuePair(key: value, value: key)
        }.nonUniquelyKeyedToDictionary { pair in
            pair
        }
    }
    
    public func inverseKeysAndValuesWithUniqueKeys() throws -> [Value: Key] {
        try map { key, value in
            KeyValuePair(key: value, value: key)
        }.uniquelyKeyedToDictionary { pair in
            pair
        }
    }
}
