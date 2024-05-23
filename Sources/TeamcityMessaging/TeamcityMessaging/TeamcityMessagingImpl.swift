// Note: it is a code from teamcity_message_generator.py (proprietary), rewritten to Swift
public final class TeamcityMessagingImpl: TeamcityMessaging {
    private let teamcityMessageGenerator: TeamcityMessageGenerator
    private let teamcityMessagingOutput: TeamcityMessagingOutput
    
    public init(
        teamcityMessageGenerator: TeamcityMessageGenerator,
        teamcityMessagingOutput: TeamcityMessagingOutput
    ) {
        self.teamcityMessageGenerator = teamcityMessageGenerator
        self.teamcityMessagingOutput = teamcityMessagingOutput
    }
    
    public func block<T>(
        name: String,
        flowId: String?,
        body: () throws -> T
    ) rethrows -> T {
        try wrap(
            messageBefore: teamcityMessageGenerator.blockOpenend(name: name, flowId: flowId),
            messageAfter: teamcityMessageGenerator.blockClosed(name: name, flowId: flowId),
            body: body
        )
    }
    
    private func wrap<T>(
        messageBefore: ControlMessage,
        messageAfter: ControlMessage,
        body: () throws -> T
    ) rethrows -> T {
        output(controlMessage: messageBefore)
        let result = try body()
        output(controlMessage: messageAfter)
        return result
    }
    
    public func block<T>(
        name: String,
        flowId: String?,
        body: () async throws -> T
    ) async rethrows -> T {
        try await wrap(
            messageBefore: teamcityMessageGenerator.blockOpenend(name: name, flowId: flowId),
            messageAfter: teamcityMessageGenerator.blockClosed(name: name, flowId: flowId),
            body: body
        )
    }
    
    private func wrap<T>(
        messageBefore: ControlMessage,
        messageAfter: ControlMessage,
        body: () async throws -> T
    ) async rethrows -> T {
        output(controlMessage: messageBefore)
        let result = try await body()
        output(controlMessage: messageAfter)
        return result
    }
    
    private func output(controlMessage: ControlMessage) {
        do {
            try teamcityMessagingOutput.output(controlMessage: controlMessage)
        } catch {
            print("Failed to output teamcity control message. Control message: \(controlMessage). Error: \(error)")
        }
    }
}
