extension Sequence {
    public func uniquelyKeyedToDictionary<Key: Hashable, Value>(
        transform: (Self.Element) throws -> KeyValuePair<Key, Value>
    ) throws -> [Key: Value] {
        try Dictionary(
            uniqueKeysWithValues: nonUniquelyKeyedToDictionary(
                transform: transform
            ).map { key, array in
                try toPairWithUniqueValue(
                    key: key,
                    array: array,
                    functionName: "uniquelyKeyedToDictionary"
                )
            }
        )
    }
    
    public func uniquelyKeyedBy<Key: Hashable>(
        keyForValue: (Self.Element) throws -> Key
    ) throws -> [Key: Self.Element] {
        try Dictionary(
            uniqueKeysWithValues: nonUniquelyKeyedBy(
                keyForValue: keyForValue
            ).map { key, array in
                try toPairWithUniqueValue(
                    key: key,
                    array: array,
                    functionName: "uniquelyKeyedBy"
                )
            }
        )
    }
    
    public func nonUniquelyKeyedBy<Key: Hashable>(
        keyForValue: (Self.Element) throws -> Key
    ) rethrows -> [Key: [Self.Element]] {
        try Dictionary(
            grouping: self,
            by: keyForValue
        )
    }
    
    public func nonUniquelyKeyedToDictionary<Key: Hashable, Value>(
        transform: (Self.Element) throws -> KeyValuePair<Key, Value>
    ) rethrows -> [Key: [Value]] {
        var dictionary = [Key: [Value]]()
        
        for element in self {
            let keyValuePair = try transform(element)
            dictionary[keyValuePair.key, default: []].append(keyValuePair.value)
        }
        
        return dictionary
    }
    
    private func toPairWithUniqueValue<Key: Hashable, Value>(
        key: Key,
        array: [Value],
        functionName: StaticString
    ) throws -> (Key, Value) {
        let element = try array.onlyOneOrThrow(
            message:
            """
            `\(functionName)` expected for unique values in sequence for key: \(key). \
            Actual count of values for key: \(array.count). Values: \(array).
            """
        )
        
        return (key, element)
    }
}
