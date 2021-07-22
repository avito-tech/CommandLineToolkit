import ArgumentParser

public typealias SAPCommandWithDi<T: SAPCommandDi> = BaseSAPCommandWithDi<T>
    & SAPCommandLogic
    & ParsableCommand
    & SAPCommandLogicProvider
