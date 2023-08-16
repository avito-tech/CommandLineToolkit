public protocol TeamcityMessageRenderer {
    func renderControlMessage(
        controlMessage: ControlMessage
    ) throws -> String
}
