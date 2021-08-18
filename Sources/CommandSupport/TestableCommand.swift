/// If you are using `CommandDiValidator`, it creates commands to validate them.
/// And if some commands have required arguments, they can not be created without them.
/// You can use `TestableCommand` to help `CommandDiValidator` create such commands.
///
/// Example:
///
/// ```
/// extension MyCommand: TestableCommand {
///     public static func testableCommandArguments() -> [String] {
///         return ["irrelevant_foo_argument", "irrelevant_bar_argument"]
///     }
/// }
/// ```

public protocol TestableCommand {
    static func testableCommandArguments() -> [String]
}
