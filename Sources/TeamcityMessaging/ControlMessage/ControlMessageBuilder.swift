public final class ControlMessageBuilder {
    public init() {
    }
    
    public func build(
        type: String
    ) -> ControlMessageWithMultipleParameters {
        return ControlMessageWithMultipleParameters(
            type: type,
            flowId: nil,
            timestamp: nil,
            parameters: []
        )
    }
    
    public func build(
        type: String,
        value: String
    ) -> ControlMessageWithSingleParameter {
        return ControlMessageWithSingleParameter(
            type: type,
            value: value
        )
    }
}
