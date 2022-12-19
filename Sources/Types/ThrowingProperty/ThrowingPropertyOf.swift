open class ThrowingPropertyOf<T>: ThrowingProperty {
    public typealias PropertyType = T
    
    private let getter: () throws -> PropertyType
    private let setter: (PropertyType) throws -> ()
    
    public init(
        getter: @escaping () throws -> PropertyType,
        setter: @escaping (PropertyType) throws -> ()
    ) {
        self.getter = getter
        self.setter = setter
    }
    
    public convenience init<Other: ThrowingProperty>(
        throwingProperty: Other
    ) where Other.PropertyType == PropertyType {
        self.init(
            getter: { try throwingProperty.get() },
            setter: { try throwingProperty.set($0) }
        )
    }
    
    public convenience init<Gettable: GettableThrowingProperty, Settable: SettableThrowingProperty>(
        gettableThrowingProperty: Gettable,
        settableThrowingProperty: Settable
    ) where Gettable.PropertyType == PropertyType, Settable.PropertyType == PropertyType {
        self.init(
            getter: { try gettableThrowingProperty.get() },
            setter: { try settableThrowingProperty.set($0) }
        )
    }
    
    public func get() throws -> PropertyType {
        try getter()
    }
    
    public func set(_ value: PropertyType) throws {
        try setter(value)
    }
}
