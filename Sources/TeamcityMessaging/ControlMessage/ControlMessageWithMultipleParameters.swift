import Foundation

public final class ControlMessageWithMultipleParameters {
    public let type: String
    public let flowId: String?
    public let timestamp: Date?
    public let parameters: [ControlMessageParameter]
    
    public init(
        type: String,
        flowId: String?,
        timestamp: Date?,
        parameters: [ControlMessageParameter]
    ) {
        self.type = type
        self.flowId = flowId
        self.timestamp = timestamp
        self.parameters = parameters
    }
    
    public func withTimestamp(
        timestamp: Date?
    ) -> ControlMessageWithMultipleParameters {
        guard let timestamp else { return self }
        
        return ControlMessageWithMultipleParameters(
            type: type,
            flowId: flowId,
            timestamp: timestamp,
            parameters: parameters
        )
    }

    public func withFlowId(
        flowId: String?
    ) -> ControlMessageWithMultipleParameters {
        guard let flowId else { return self }
        
        return ControlMessageWithMultipleParameters(
            type: type,
            flowId: flowId,
            timestamp: timestamp,
            parameters: parameters
        )
    }
            
    public func withParameter(
        name: String,
        value: String?
    ) -> ControlMessageWithMultipleParameters {
        guard let value else { return self }
        
        return ControlMessageWithMultipleParameters(
            type: type,
            flowId: flowId,
            timestamp: timestamp,
            parameters: parameters + [ControlMessageParameter(
                name: name,
                value: value
            )]
        )
    }
    
    public func toControlMessage() -> ControlMessage {
        return .withMultipleParameters(self)
    }
}
