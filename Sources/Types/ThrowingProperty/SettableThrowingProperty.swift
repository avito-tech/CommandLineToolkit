public protocol SettableThrowingProperty {
    associatedtype PropertyType
    
    func set(_ value: PropertyType) throws
}
