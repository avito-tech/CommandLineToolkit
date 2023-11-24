import XCTest
import ArgumentParser

import CommandSupport

final class ParsableCommandPathTests: XCTestCase {

    struct RootCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "root",
            subcommands: [SubCommandA.self, SubCommandB.self]
        )
    }

    struct SubCommandA: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "subA",
            subcommands: [SubSubCommandA1.self]
        )
    }

    struct SubSubCommandA1: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "subA1")
    }

    struct SubCommandB: ParsableCommand {
        static var configuration = CommandConfiguration(commandName: "subB")
    }

    func test___path___returns_correct_path___with_root_command_path() throws {
        let path = try RootCommand.path(fromRootCommand: RootCommand.self)
        XCTAssertEqual(path, "root")
    }

    func test___path___returns_correct_path___with_sub_command_path() throws {
        let path = try SubCommandA.path(fromRootCommand: RootCommand.self)
        XCTAssertEqual(path, "root subA")
    }

    func test___path___returns_correct_path___with_nested_sub_commands_path() throws {
        let path = try SubSubCommandA1.path(fromRootCommand: RootCommand.self)
        XCTAssertEqual(path, "root subA subA1")
    }

    func test___path___throws_commandNotFoundInTree___with_invalid_command_path() {
        XCTAssertThrowsError(try SubCommandA.path(fromRootCommand: SubCommandB.self)) { error in
            guard let pathError = error as? ParsableCommandPathError else {
                return XCTFail("Wrong error type")
            }
            XCTAssertEqual(pathError, .commandNotFoundInTree)
        }
    }
}
