public protocol SAPCommandLogicProvider {
    func commandLogic() throws -> SAPCommandLogic
}
