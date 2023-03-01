public func +<T: Hashable>(lhs: Set<T>, rhs: Set<T>) -> Set<T> {
    return lhs.union(rhs)
}

public func +<T: Hashable>(lhs: [T], rhs: Set<T>) -> Set<T> {
    return rhs.union(lhs)
}

public func +<T: Hashable>(lhs: Set<T>, rhs: [T]) -> Set<T> {
    return lhs.union(rhs)
}
