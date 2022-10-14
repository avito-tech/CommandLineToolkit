extension Array where Element: Hashable {
    public func uniquified() -> [Element] {
        Array(toSet())
    }
    
    public func uniquified<V: Hashable>(by keyPath: KeyPath<Element, V>) -> [Element] {
        var processedValues = Set<V>()
        
        var result = [Element]()
        
        for element in self {
            let value = element[keyPath: keyPath]
            if processedValues.insert(value).inserted {
                result.append(element)
            }
        }
        
        return result
    }
    
    public func toSet() -> Set<Element> {
        Set(self)
    }
}
