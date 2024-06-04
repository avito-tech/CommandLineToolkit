import Foundation

/// Builds messages according to:
/// https://www.jetbrains.com/help/teamcity/service-messages.html
///
/// Note that there's a library for teamcity messages: https://github.com/JetBrains/teamcity-messages
/// It can be used to wrap mypy/unittests/flake8 in teamcity messages. It can not really be used
/// for custom messaging: it is not a generic purpose library, also it lacks typing, easy interfaces, extendability.
public final class TeamcityMessageGenerator {
    private let controlMessageBuilder = ControlMessageBuilder()
    
    /// Blocks are used to group several messages in the build log.
    public func blockOpenend(
        name: String,
        description: String? = nil,
        timestamp: Date? = nil,
        flowId: String? = nil
    ) -> ControlMessage {
        controlMessageBuilder
            .build(type: "blockOpened")
            .withParameter(name: "name", value: name)
            .withParameter(name: "description", value: description)
            .withTimestamp(timestamp: timestamp)
            .withFlowId(flowId: flowId)
            .toControlMessage()
    }

    /// Note that when you close a block, all its inner blocks are closed automatically.
    public func blockClosed(
        name: String,
        timestamp: Date? = nil,
        flowId: String? = nil
    ) -> ControlMessage {
        controlMessageBuilder
            .build(type: "blockClosed")
            .withParameter(name: "name", value: name)
            .withTimestamp(timestamp: timestamp)
            .withFlowId(flowId: flowId)
            .toControlMessage()
    }

    /// Note that when you close a block, all its inner blocks are closed automatically.
    public func flowStarted(
        name: String,
        timestamp: Date? = nil,
        flowId: String,
        parentFlowId: String?
    ) -> ControlMessage {
        controlMessageBuilder
            .build(type: "flowStarted")
            .withParameter(name: "name", value: name)
            .withParameter(name: "parent", value: parentFlowId)
            .withTimestamp(timestamp: timestamp)
            .withFlowId(flowId: flowId)
            .toControlMessage()
    }

    /// Note that when you close a block, all its inner blocks are closed automatically.
    public func flowFinished(
        timestamp: Date? = nil,
        flowId: String
    ) -> ControlMessage {
        controlMessageBuilder
            .build(type: "flowFinished")
            .withTimestamp(timestamp: timestamp)
            .withFlowId(flowId: flowId)
            .toControlMessage()
    }

    /// Note that when you close a block, all its inner blocks are closed automatically.
    public func message(
        text: String,
        status: MessageStatus? = nil,
        timestamp: Date? = nil,
        flowId: String? = nil
    ) -> ControlMessage {
        controlMessageBuilder
            .build(type: "message")
            .withTimestamp(timestamp: timestamp)
            .withFlowId(flowId: flowId)
            .withParameter(name: "text", value: text)
            .withParameter(name: "status", value: status?.rawValue)
            .toControlMessage()
    }
}

public enum MessageStatus: String {
    case normal = "NORMAL"
    case warning = "WARNING"
    case failure = "FAILURE"
}
