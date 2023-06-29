import Foundation
import XCTest
@testable import Console

final class LogRendererTests: XCTestCase {
    let renderer = LogComponentRenderer()

    func testBasicTraceLog() {
        let state = LogComponentRenderer.State(
            level: .trace,
            message: "Trace log message",
            metadata: [:],
            source: "",
            file: "FakeFile.swift",
            function: #function,
            line: 1
        )

        expect(state) {
            """
            ╶ Trace log message
            """
        }
    }

    func testBasicInfoLog() {
        let state = LogComponentRenderer.State(
            level: .info,
            message: "Info log message",
            metadata: [:],
            source: "",
            file: "FakeFile.swift",
            function: #function,
            line: 1
        )

        expect(state) {
            """
            ╶ Info log message
            """
        }
    }

    func testMultilineInfoLog() {
        let state = LogComponentRenderer.State(
            level: .info,
            message: "Info log message\nsecond line",
            metadata: [:],
            source: "",
            file: "FakeFile.swift",
            function: #function,
            line: 1
        )

        expect(state) {
            """
            ╭ Info log message
            │ second line
            ╰
            """
        }
    }

    func testMultilineInfoLogWithMeta() {
        let state = LogComponentRenderer.State(
            level: .info,
            message: "Info log message\nsecond line",
            metadata: ["key": "value"],
            source: "",
            file: "FakeFile.swift",
            function: #function,
            line: 1
        )

        expect(state) {
            """
            ╭ Info log message
            │ second line
            ├─────────────────
            │ key: value
            ╰
            """
        }
    }

    func testBasicInfoLogWithMeta() {
        let state = LogComponentRenderer.State(
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

        expect(state) {
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
    }

    func expect(_ state: LogComponentRenderer.State, file: StaticString = #file, line: UInt = #line, buildText: () -> String) {
        let component = renderer.render(state: state, preferredSize: nil)
        let text = component.lines.map(\.description).joined(separator: "\n")
        XCTAssertEqual(text, buildText(), file: file, line: line)
    }
}
