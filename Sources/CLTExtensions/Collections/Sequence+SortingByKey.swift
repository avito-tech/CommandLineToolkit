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
        return try sorted { lhs, rhs in
            try key(lhs) < key(rhs)
        }
    }
    
    public func sortedDescendingBy<Key: Comparable>(
        key: (Element) throws -> Key
    ) rethrows -> [Element] {
        return try sorted { lhs, rhs in
            try key(lhs) > key(rhs)
        }
    }
}
