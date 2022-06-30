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
/// class MyProjectDependencies: ModuleDependencies {
///     func registerDependenciesOfCurrentModule(di: DependencyRegisterer) {
///         di.register(type: MyType.self) { _ in
///             MyTypeImpl()
///         }
///     }
///
///     func otherModulesDependecies() -> [ModuleDependencies] {
///         [...]
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

import DI

open class BaseCommand<T> where
    T: ModuleDependencies,
    T: InitializableWithNoArguments
{
    public let di: DependencyInjection = DiMaker<T>.makeDi()
    
    public init() {
    }
}
