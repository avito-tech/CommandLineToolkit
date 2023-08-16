import Foundation
import CLTExtensions

public final class TeamcityMessagingOutputImpl: TeamcityMessagingOutput {
    private let teamcityMessageRenderer: TeamcityMessageRenderer
    
    public init(
        teamcityMessageRenderer: TeamcityMessageRenderer
    ) {
        self.teamcityMessageRenderer = teamcityMessageRenderer
    }
    
    public func output(controlMessage: ControlMessage) throws {
        let standardError = FileHandle.standardError
        
        let messageString = try teamcityMessageRenderer.renderControlMessage(
            controlMessage: controlMessage
        )
        
        standardError.write(try "\(messageString)\n".dataUsingUtf8())
        try? standardError.synchronize() // Sometimes it works, sometimes it doesn't, hence `try?`
    }
}
