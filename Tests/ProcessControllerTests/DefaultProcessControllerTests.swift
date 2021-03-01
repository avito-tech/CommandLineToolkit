import DateProvider
import FileSystem
import Foundation
import PathLib
import ProcessController
import Tmp
import TestHelpers
import XCTest

final class DefaultProcessControllerTests: XCTestCase {
    private let dateProvider = SystemDateProvider()
    private let fileSystem = LocalFileSystem()
    
    func testStartingSimpleSubprocess() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/usr/bin/env"]
            )
        )
        try controller.startAndListenUntilProcessDies()
        XCTAssertEqual(controller.processStatus(), .terminated(exitCode: 0))
    }
    
    func test___termination_status_is_running___when_process_is_running() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep", "10"]
            )
        )
        try controller.start()
        XCTAssertEqual(controller.processStatus(), .stillRunning)
    }
    
    func test___termination_status_is_not_started___when_process_has_not_yet_started() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/usr/bin/env"]
            )
        )
        XCTAssertEqual(controller.processStatus(), .notStarted)
    }
    
    func test___process_cannot_be_started___when_file_does_not_exist() {
        assertThrows {
            try DefaultProcessController(
                dateProvider: dateProvider,
                fileSystem: fileSystem,
                subprocess: Subprocess(
                    arguments: ["/bin/non/existing/file/\(ProcessInfo.processInfo.globallyUniqueString)"]
                )
            )
        }
    }
    
    func test___process_cannot_be_started___when_file_is_not_executable() {
        let tempFile = assertDoesNotThrow { try TemporaryFile() }
        
        assertThrows {
            try DefaultProcessController(
                dateProvider: dateProvider,
                fileSystem: fileSystem,
                subprocess: Subprocess(
                    arguments: [tempFile.absolutePath]
                )
            )
        }
    }
    
    func test___successful_termination___does_not_throw() throws {
        let controller = assertDoesNotThrow {
            try DefaultProcessController(
                dateProvider: dateProvider,
                fileSystem: fileSystem,
                subprocess: Subprocess(
                    arguments: ["/usr/bin/env"]
                )
            )
        }
        assertDoesNotThrow {
            try controller.startAndWaitForSuccessfulTermination()
        }
    }
    
    func test___termination_with_non_zero_exit_code___throws() throws {
        let argument = "/\(UUID().uuidString)"
        let controller = assertDoesNotThrow {
            try DefaultProcessController(
                dateProvider: dateProvider,
                fileSystem: fileSystem,
                subprocess: Subprocess(
                    arguments: ["/bin/ls", argument]
                )
            )
        }
        try controller.startAndListenUntilProcessDies()
        
        assertThrows {
            try controller.startAndWaitForSuccessfulTermination()
        }
    }
    
    func test___successful_execution() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep", "0.01"]
            )
        )
        try controller.startAndListenUntilProcessDies()
        XCTAssertEqual(controller.processStatus(), .terminated(exitCode: 0))
    }
        
    func test___automatic_interrupt_silence_handler() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep", "999"],
                automaticManagement: .sigintThenKillIfSilent(interval: 0.00001)
            )
        )
        try controller.startAndListenUntilProcessDies()
        XCTAssertEqual(controller.processStatus(), .terminated(exitCode: SIGINT))
    }
    
    func test___automatic_terminate_silence_handler() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep", "999"],
                automaticManagement: .sigtermThenKillIfSilent(interval: 0.00001)
            )
        )
        try controller.startAndListenUntilProcessDies()
        XCTAssertEqual(controller.processStatus(), .terminated(exitCode: SIGTERM))
    }
    
    func testWhenSubprocessFinishesSilenceIsNotReported() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep"],
                automaticManagement: .sigtermThenKillIfSilent(interval: 10.0)
            )
        )
        var signalled = false
        controller.onSignal { _, _, _ in
            signalled = true
        }
        try controller.startAndListenUntilProcessDies()

        XCTAssertFalse(signalled)
    }
    
    func test__executing_from_specific_working_directory() throws {
        let temporaryFolder = try TemporaryFolder()
        
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/pwd"],
                workingDirectory: temporaryFolder.absolutePath
            )
        )
        
        var output = ""
        controller.onStdout { _, data, _ in
            output = String(data: data, encoding: .utf8) ?? ""
        }
        
        try controller.startAndListenUntilProcessDies()
        
        XCTAssertEqual(
            output,
            temporaryFolder.absolutePath.pathString + "\n"
        )
    }
    
    func test___stdout_listener() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/ls", "/bin/ls"],
                environment: ["NSUnbufferedIO": "YES"]
            )
        )
        
        var stdoutData = Data()
        controller.onStdout { _, data, _ in stdoutData.append(contentsOf: data) }
        try controller.startAndListenUntilProcessDies()
        
        guard let string = String(data: stdoutData, encoding: .utf8) else {
            return XCTFail("Unable to get stdout string")
        }
        XCTAssertEqual(string, "/bin/ls\n")
    }
    
    func test___stderr_listener() throws {
        let argument = UUID().uuidString + UUID().uuidString
        
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/ls", "/bin/" + argument]
            )
        )
        
        var stderrData = Data()
        controller.onStderr { _, data, _ in stderrData.append(contentsOf: data) }
        try controller.startAndListenUntilProcessDies()
        
        guard let string = String(data: stderrData, encoding: .utf8) else {
            return XCTFail("Unable to get stdout string")
        }
        XCTAssertEqual(string, "ls: /bin/\(argument): No such file or directory\n")
    }
    
    func test___start_listener() throws {
        let argument = UUID().uuidString + UUID().uuidString
        
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/ls", "/bin/" + argument]
            )
        )
        
        let handlerInvoked = XCTestExpectation(description: "Start handler has been invoked")
        controller.onStart { _, _ in
            handlerInvoked.fulfill()
        }
        try controller.startAndListenUntilProcessDies()
        
        wait(for: [handlerInvoked], timeout: 10)
    }
    
    func test___termination_listener() throws {
        let argument = UUID().uuidString + UUID().uuidString
        
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/ls", "/bin/" + argument]
            )
        )
        
        let handlerInvoked = XCTestExpectation(description: "Termination handler has been invoked")
        controller.onTermination { _, _ in
            handlerInvoked.fulfill()
        }
        try controller.startAndListenUntilProcessDies()
        
        wait(for: [handlerInvoked], timeout: 10)
    }
    
    func test___callers_waits_for_process_to_die___all_termination_handlers_invoked_before_returning() throws {
        let expectation = XCTestExpectation(description: "Termination handler has finished")
        
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/usr/bin/env"]
            )
        )
        controller.onTermination { _, _ in
            Thread.sleep(forTimeInterval: 5)
            expectation.fulfill()
        }
        
        try controller.startAndListenUntilProcessDies()
        wait(for: [expectation], timeout: 0)
    }
    
    func test___sigterm_is_sent___when_silent() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep", "10"],
                automaticManagement: .sigtermThenKillIfSilent(interval: 0.01)
            )
        )
        
        let listenerCalled = expectation(description: "Silence listener has been invoked")
        
        controller.onSignal { _, signal, unsubscriber in
            XCTAssertEqual(signal, SIGTERM)
            unsubscriber()
            listenerCalled.fulfill()
        }
        try controller.start()
        defer { controller.forceKillProcess() }
        
        wait(for: [listenerCalled], timeout: 10)
    }
    
    func test___sigint_is_sent___when_silent() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep", "10"],
                automaticManagement: .sigintThenKillIfSilent(interval: 0.01)
            )
        )
        
        let listenerCalled = expectation(description: "Silence listener has been invoked")
        
        controller.onSignal { _, signal, unsubscriber in
            XCTAssertEqual(signal, SIGINT)
            unsubscriber()
            listenerCalled.fulfill()
        }
        try controller.start()
        defer { controller.forceKillProcess() }
        
        wait(for: [listenerCalled], timeout: 10)
    }
    
    func test___sigint_is_sent___when_running_for_too_long() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep", "99"],
                automaticManagement: .sigintThenKillAfterRunningFor(interval: 1)
            )
        )
        
        let listenerCalled = expectation(description: "Signal listener has been invoked")
        
        controller.onSignal { _, signal, unsubscriber in
            XCTAssertEqual(signal, SIGINT)
            unsubscriber()
            listenerCalled.fulfill()
        }
        try controller.start()
        defer { controller.forceKillProcess() }
        wait(for: [listenerCalled], timeout: 10)
    }
    
    func test___sigterm_is_sent___when_running_for_too_long() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sleep", "99"],
                automaticManagement: .sigtermThenKillAfterRunningFor(interval: 1)
            )
        )
        
        let listenerCalled = expectation(description: "Signal listener has been invoked")
        
        controller.onSignal { _, signal, unsubscriber in
            XCTAssertEqual(signal, SIGTERM)
            unsubscriber()
            listenerCalled.fulfill()
        }
        try controller.start()
        defer { controller.forceKillProcess() }
        wait(for: [listenerCalled], timeout: 10)
    }
    
    func test___cancelling_stdout_listener___does_not_invoke_cancelled_listener_anymore() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sh", "-c", "echo aa; sleep 3; echo aa"]
            )
        )
        
        var collectedData = Data()
        
        controller.onStdout { _, data, unsubscriber in
            collectedData.append(contentsOf: data)
            unsubscriber()
        }
        try controller.startAndListenUntilProcessDies()
        
        XCTAssertEqual(
            collectedData,
            "aa\n".data(using: .utf8)
        )
    }
    
    func test___cancelling_stderr_listener___does_not_invoke_cancelled_listener_anymore() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sh", "-c", ">&2 echo aa; sleep 3; echo aa"]
            )
        )
        
        var collectedData = Data()
        
        controller.onStderr { _, data, unsubscriber in
            collectedData.append(contentsOf: data)
            unsubscriber()
        }
        try controller.startAndListenUntilProcessDies()
        
        XCTAssertEqual(
            collectedData,
            "aa\n".data(using: .utf8)
        )
    }
    
    func test___passing_env() throws {
        let controller = try DefaultProcessController(
            dateProvider: dateProvider,
            fileSystem: fileSystem,
            subprocess: Subprocess(
                arguments: ["/bin/sh", "-c", "echo $ENV_NAME"],
                environment: ["ENV_NAME": "VALUE"]
            )
        )
        let outputExpectation = XCTestExpectation()
        controller.onStdout { _, data, _ in
            XCTAssertEqual(
                data,
                "VALUE\n".data(using: .utf8)
            )
            outputExpectation.fulfill()
        }
        try controller.startAndWaitForSuccessfulTermination()
        
        wait(for: [outputExpectation], timeout: 60)
    }
    
    func test___throws_objc_exceptions_as_swift_errors() throws {
        let tempFile = assertDoesNotThrow { try TemporaryFile() }
        
        try fileSystem.properties(forFileAtPath: tempFile.absolutePath).set(permissions: 0o755)
        
        assertThrows {
            try DefaultProcessController(
                dateProvider: dateProvider,
                fileSystem: fileSystem,
                subprocess: Subprocess(
                    arguments: [tempFile.absolutePath]
                )
            ).start()
        }
    }
}
