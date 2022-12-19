open class GettableThrowingPropertyOf<T>: GettableThrowingProperty {
    public typealias PropertyType = T
    
    private let getter: () throws -> PropertyType
    
    public init(
        getter: @escaping () throws -> PropertyType
    ) {
        self.getter = getter
    }
    
    public convenience init<Other: GettableThrowingProperty>(
        throwingProperty: Other
    ) where Other.PropertyType == PropertyType {
        self.init(
            getter: { try throwingProperty.get() }
        )
    }
    public func get() throws -> PropertyType {
        try getter()
    }
}
