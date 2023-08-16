public final class ControlMessageWithSingleParameter {
    public let type: String
    public let value: String
    
    public init(
        type: String,
        value: String
    ) {
        self.type = type
        self.value = value
    }
    
    public func toControlMessage() -> ControlMessage {
        return .withSingleParameter(self)
    }
}
