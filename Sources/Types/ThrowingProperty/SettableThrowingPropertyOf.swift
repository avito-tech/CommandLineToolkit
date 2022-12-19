open class SettableThrowingPropertyOf<T>: SettableThrowingProperty {
    public typealias PropertyType = T
    
    private let setter: (PropertyType) throws -> ()
    
    public init(
        setter: @escaping (PropertyType) throws -> ()
    ) {
        self.setter = setter
    }
    
    public convenience init<Other: SettableThrowingProperty>(
        throwingProperty: Other
    ) where Other.PropertyType == PropertyType {
        self.init(
            setter: { try throwingProperty.set($0) }
        )
    }
    
    public func set(_ value: PropertyType) throws {
        try setter(value)
    }
}
