public protocol CommandLogicProvider {
    func commandLogic() throws -> CommandLogic
}
