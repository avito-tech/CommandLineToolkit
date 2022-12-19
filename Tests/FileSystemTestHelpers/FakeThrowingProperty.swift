import Types

public final class FakeThrowingProperty<T>: ThrowingPropertyOf<T> {
    public var value: T {
        get {
            valueBox.value
        }
        set {
            valueBox.value = newValue
        }
    }
    
    private let valueBox: MutableBox<T>
    
    public init(value: T) {
        let valueBox = MutableBox(value: value)
        
        self.valueBox = valueBox
        
        super.init(
            getter: { valueBox.value },
            setter: { valueBox.value = $0 }
        )
    }
}
