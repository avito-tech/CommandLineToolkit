import Foundation
import XCTest
import InlineSnapshotTesting
@testable import Console

final class LogRendererTests: XCTestCase {
    let renderer = LogComponentRenderer()
    
    override func invokeTest() {
        withSnapshotTesting(record: .never) {
            super.invokeTest()
        }
    }

    func testBasicTraceLog() {
        let component = LogComponent(
            state: .init(
                level: .trace,
                message: "Trace log message",
                metadata: [:],
                source: "",
                file: "FakeFile.swift",
                function: #function,
                line: 1
            )
        )
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╶ Trace log message
            """
        }

        assertInlineSnapshot(of: component, as: .consoleRaw(verbositySettings: .verbose)) {
            """
            ╶ Trace log message
            """
        }
    }

    func testBasicInfoLog() {
        let component = LogComponent(
            state: .init(
                level: .info,
                message: "Info log message",
                metadata: [:],
                source: "",
                file: "FakeFile.swift",
                function: #function,
                line: 1
            )
        )

        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╶ Info log message
            """
        }
        
        assertInlineSnapshot(of: component, as: .consoleRaw(verbositySettings: .verbose)) {
            """
            ^[38;5;36m╶^[0m ^[38;5;36mInfo log message^[0m
            """
        }
    }

    func testMultilineInfoLog() {
        let component = LogComponent(
            state: .init(
                level: .info,
                message: "Info log message\nsecond line",
                metadata: [:],
                source: "",
                file: "FakeFile.swift",
                function: #function,
                line: 1
            )
        )
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Info log message
            │ second line
            ╰
            """
        }

        assertInlineSnapshot(of: component, as: .consoleRaw(verbositySettings: .verbose)) {
            """
            ^[38;5;36m╭^[0m ^[38;5;36mInfo log message^[0m
            ^[38;5;36m│^[0m ^[38;5;36msecond line^[0m
            ^[38;5;36m╰^[0m
            """
        }
    }

    func testMultilineInfoLogWithMeta() {
        let component = LogComponent(
            state: .init(
                level: .info,
                message: "Info log message\nsecond line",
                metadata: ["key": "value"],
                source: "",
                file: "FakeFile.swift",
                function: #function,
                line: 1
            )
        )
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Info log message
            │ second line
            ├─────────────────
            │ key: value
            ╰
            """
        }

        assertInlineSnapshot(of: component, as: .consoleRaw(verbositySettings: .verbose)) {
            """
            ^[38;5;36m╭^[0m ^[38;5;36mInfo log message^[0m
            ^[38;5;36m│^[0m ^[38;5;36msecond line^[0m
            ^[38;5;36m├^[0m^[38;5;36m─────────────────^[0m
            ^[38;5;36m│^[0m ^[38;5;36mkey: value^[0m
            ^[38;5;36m╰^[0m
            """
        }
    }

    func testBasicInfoLogWithMeta() {
        let component = LogComponent(
            state: .init(
                level: .info,
                message: "Info log message with meta",
                metadata: [
                    "string": "value",
                    "string-convertible": .stringConvertible(10),
                    "array-of-strings": [
                        "first",
                        "second",
                    ],
                    "array-of-objects": [
                        [
                            "key1": "value1",
                            "key2": "value2"
                        ],
                        [
                            "key3": "value3",
                            "key4": "value4"
                        ]
                    ]
                ],
                source: "",
                file: "FakeFile.swift",
                function: #function,
                line: 1
            )
        )
        
        assertInlineSnapshot(of: component, as: .consoleText(verbositySettings: .verbose)) {
            """
            ╭ Info log message with meta
            ├───────────────────────────
            │ array-of-objects:
            │ - key1: value1
            │   key2: value2
            │ - key3: value3
            │   key4: value4
            │ array-of-strings:
            │ - first
            │ - second
            │ string: value
            │ string-convertible: '10'
            ╰
            """
        }

        assertInlineSnapshot(of: component, as: .consoleRaw(verbositySettings: .verbose)) {
            """
            ^[38;5;36m╭^[0m ^[38;5;36mInfo log message with meta^[0m
            ^[38;5;36m├^[0m^[38;5;36m───────────────────────────^[0m
            ^[38;5;36m│^[0m ^[38;5;36marray-of-objects:^[0m
            ^[38;5;36m│^[0m ^[38;5;36m- key1: value1^[0m
            ^[38;5;36m│^[0m ^[38;5;36m  key2: value2^[0m
            ^[38;5;36m│^[0m ^[38;5;36m- key3: value3^[0m
            ^[38;5;36m│^[0m ^[38;5;36m  key4: value4^[0m
            ^[38;5;36m│^[0m ^[38;5;36marray-of-strings:^[0m
            ^[38;5;36m│^[0m ^[38;5;36m- first^[0m
            ^[38;5;36m│^[0m ^[38;5;36m- second^[0m
            ^[38;5;36m│^[0m ^[38;5;36mstring: value^[0m
            ^[38;5;36m│^[0m ^[38;5;36mstring-convertible: '10'^[0m
            ^[38;5;36m╰^[0m
            """
        }
    }
}
