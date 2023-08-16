public protocol TeamcityMessagingOutput {
    func output(controlMessage: ControlMessage) throws
}
