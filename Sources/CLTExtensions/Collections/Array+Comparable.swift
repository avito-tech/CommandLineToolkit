extension Array: @retroactive Comparable where Element: Comparable {
    public static func <(lhs: Array, rhs: Array) -> Bool {
        for i in 0..<Swift.min(lhs.count, rhs.count) {
            if lhs[i] != rhs[i] { return lhs[i] < rhs[i] }
        }
        
        return lhs.count < rhs.count
    }
}
