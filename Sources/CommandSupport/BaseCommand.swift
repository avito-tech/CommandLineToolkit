/// # Example (create those files and name accordingly):
///
/// ## Command.swift (boilerplate):
///
/// ```
/// import ArgumentParser
/// import CommandSupport
///
/// public typealias Command = BaseCommand<MyProjectDependencies>
///     & CommandLogic
///     & ParsableCommand
///     & CommandLogicProvider
///
/// extension CommandLogicProvider where Self: Command {
///     public func run() throws {
///         try commandLogic().run()
///     }
/// }
/// ```
///
/// ## MyProjectDependencies.swift (declare all your dependencies):
///
/// ```
/// class MyProjectDependencies: DependencyCollectionRegisterer {
///     func register(dependencyRegisterer di: DependencyRegisterer) {
///         di.register(type: MyType.self) { _ in
///             MyTypeImpl()
///         }
///     }
/// }
/// ```
///
/// ## MyCommand.swift (declare your command as in ArgumentParser, but without `run()`):
///
/// ```
/// public final class MyCommand: Command {
///     public func commandLogic() throws -> CommandLogic {
///         return MyCommandLogic(
///             myType: try di.resolve(),
///         )
///     }
/// }
///
/// public final class MyCommandLogic: CommandLogic {
///     public init(
///         myType: MyType,
///     ) {
///         self.myType = myType
///     }
///
///     public func run() throws {
///         myType.doSomething()
///     }
/// }
/// ```

import MixboxDi
import MixboxBuiltinDi

open class BaseCommand<T> where
    T: DependencyCollectionRegisterer,
    T: InitializableWithNoArguments
{
    public let di: DependencyInjection = makeDi()
    
    public init() {
    }
    
    private static func makeDi() -> DependencyInjection {
        let di = BuiltinDependencyInjection()
        
        T().register(dependencyRegisterer: di)
        
        return di
    }
}

