extension Sequence {
    public func sortedBy<Key: Comparable>(
        key: (Element) throws -> Key,
        ascending: Bool
    ) rethrows -> [Element] {
        try ascending
            ? sortedAscendingBy(key: key)
            : sortedDescendingBy(key: key)
    }
    
    public func sortedAscendingBy<Key: Comparable>(
        key: (Element) throws -> Key
    ) rethrows -> [Element] {
        try sortedBySingleKey(key: key, operator: <)
    }
    
    public func sortedDescendingBy<Key: Comparable>(
        key: (Element) throws -> Key
    ) rethrows -> [Element] {
        try sortedBySingleKey(key: key, operator: >)
    }
    
    private func sortedBySingleKey<Key: Comparable>(
        key: (Element) throws -> Key,
        operator: (Key, Key) -> Bool
    ) rethrows -> [Element] {
        return try sorted { lhs, rhs in
            try `operator`(key(lhs), key(rhs))
        }
    }
}
