extension Array where Element: Hashable {
    public func uniquify() -> [Element] {
        return Array(Set(self))
    }
}
