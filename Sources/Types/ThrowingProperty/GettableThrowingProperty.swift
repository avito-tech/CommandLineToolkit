// Note: if you don't use  (or plan to use) `SettableThrowingProperty`, consider using Swift's throwable properties.
public protocol GettableThrowingProperty {
    associatedtype PropertyType
    
    func get() throws -> PropertyType
}
