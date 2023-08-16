public enum ControlMessage {
    case withSingleParameter(ControlMessageWithSingleParameter)
    case withMultipleParameters(ControlMessageWithMultipleParameters)
    
    public var type: String {
        switch self {
        case .withSingleParameter(let message):
            return message.type
        case .withMultipleParameters(let message):
            return message.type
        }
    }
}
