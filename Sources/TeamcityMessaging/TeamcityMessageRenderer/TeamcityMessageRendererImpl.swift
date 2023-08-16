import Foundation

public final class TeamcityMessageRendererImpl: TeamcityMessageRenderer {
    private let timestampDateFormatter = DateFormatter()
    
    public init() {
        timestampDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    }
    
    public func renderControlMessage(
       controlMessage: ControlMessage
    ) throws -> String {
        let parametersString = parametersString(controlMessage: controlMessage)
        
        if !controlMessage.type.allSatisfy({ $0.isLetter || $0.isNumber }) {
            throw "controlMessage.type was expected to be alphanumeric. controlMessage.type: \(controlMessage.type)"
        }

        return "##teamcity[\(controlMessage.type) \(parametersString)]"
    }
    
    private func parametersString(
        controlMessage: ControlMessage
    ) -> String {
        switch controlMessage {
        case .withSingleParameter(let controlMessage):
            return render(controlMessage: controlMessage)
        case .withMultipleParameters(let controlMessage):
            return render(controlMessage: controlMessage)
        }
    }
    
    private func render(
        controlMessage: ControlMessageWithSingleParameter
    ) -> String {
        "'\(escape(string: controlMessage.value))'"
    }
    
    private func render(
        controlMessage: ControlMessageWithMultipleParameters
    ) -> String {
        var parameters = controlMessage.parameters

        if let timestamp = controlMessage.timestamp {
            parameters.append(
                ControlMessageParameter(
                    name: "timestamp",
                    value: renderTimestamp(
                        timestamp: timestamp
                    )
                )
            )
        }

        if let flowId = controlMessage.flowId {
            parameters.append(
                ControlMessageParameter(
                    name: "flowId",
                    value: flowId
                )
            )
        }

        return parameters.map { controlMessageParameter in
            renderControlMessageParameter(
                controlMessageParameter: controlMessageParameter
            )
        }.joined(separator: " ")
    }
    
    func renderTimestamp(
        timestamp: Date
    ) -> String {
        timestampDateFormatter.string(from: timestamp)
    }
    
    func renderControlMessageParameter(
        controlMessageParameter: ControlMessageParameter
    ) -> String {
        let escapedValue = escape(string: controlMessageParameter.value)

        return "\(controlMessageParameter.name)='\(escapedValue)'"
    }

    func escape(string: String) -> String {
        // https://www.jetbrains.com/help/teamcity/service-messages.html#Escaped+values
        // https://github.com/JetBrains/teamcity-messages/blob/1793fbf584fbcabd23f98063c1389a7c959df258/teamcity/messages.py#L24
        // Note: misses code to escape unicode characters: \uNNNN (unicode symbol with code 0xNNNN) -> |0xNNNN
        
        let escapeSequenceByCharacter: [Character: String] = [
            "'": "|'",
            "|": "||",
            "\n": "|n",
            "\r": "|r",
            "[": "|[",
            "]": "|]",
        ]
        
        return string.flatMap { character in
            escapeSequenceByCharacter[character] ?? String(character)
        }.joined(separator: "")
    }
}
