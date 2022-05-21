extension Array where Element: Hashable {
    public func uniquified() -> [Element] {
        Array(toSet())
    }
    
    public func toSet() -> Set<Element> {
        Set(self)
    }
}
