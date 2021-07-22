import ArgumentParser
import MixboxDi
import MixboxBuiltinDi

open class BaseSAPCommandWithDi<T: SAPCommandDi> {
    public let di: DependencyInjection
    
    public init() {
        self.di = Self.makeDi()
    }
    
    public static func makeDi() -> DependencyInjection {
        let di = BuiltinDependencyInjection()
        T().register(dependencyRegisterer: di)
        return di
    }
}

extension SAPCommandLogicProvider where Self: ParsableCommand {
    public func run() throws {
        try commandLogic().run()
    }
}
