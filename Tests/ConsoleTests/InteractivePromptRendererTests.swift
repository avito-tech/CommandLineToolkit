import XCTest

@testable import Console

final class InteractivePromptRendererTests: XCTestCase {

    func test___question_rendering___wraps_content_and_shows_answer_hint() {
        let sut = QuestionComponentRenderer()
        let state = QuestionComponentState(
            title: "Первая часть\nВторая часть",
            defaultAnswer: false,
            help: "help-marker help-marker help-marker help-marker"
        )

        let result = sut.render(state: state, preferredSize: Size(rows: 30, cols: 32))
        let text = result.lines.map(\.description).joined(separator: " ")

        XCTAssert(result.lines.allSatisfy { $0.description.count <= 32 })
        XCTAssertFalse(text.contains("…"))
        XCTAssertEqual(result.lines.filter { $0.description.contains("y/[N]") }.count, 1)
        XCTAssert(text.contains("help-marker"))
    }

    func test___question_rendering___keeps_long_title_and_answer_hint_within_terminal_width() {
        let sut = QuestionComponentRenderer()
        let state = QuestionComponentState(
            title: "title-marker title-marker title-marker title-marker title-marker",
            defaultAnswer: false,
            help: nil
        )

        let result = sut.render(state: state, preferredSize: Size(rows: 30, cols: 32))

        XCTAssert(result.lines.allSatisfy { $0.description.count <= 32 })
        XCTAssert(result.lines.map(\.description).joined(separator: " ").contains("y/[N]"))
    }

    func test___input_rendering___wraps_long_title_and_help() {
        let sut = InputComponentRenderer()
        let state = InputComponentState(
            title: "title-marker title-marker title-marker",
            defaultValue: nil,
            help: "help-marker help-marker help-marker"
        )

        let result = sut.render(state: state, preferredSize: Size(rows: 20, cols: 28))
        let text = result.lines.map(\.description).joined(separator: " ")

        XCTAssert(result.lines.allSatisfy { $0.description.count <= 28 })
        XCTAssertFalse(text.contains("…"))
        XCTAssert(text.contains("title-marker"))
        XCTAssert(text.contains("help-marker"))
    }

    func test___select_rendering___wraps_title_and_controls_help() {
        let sut = SelectComponentRenderer<String>()
        let state = SelectComponentState(
            title: "title-marker title-marker title-marker",
            values: [
                Selectable(
                    title: "value-marker",
                    help: "help-marker help-marker help-marker",
                    value: "value"
                )
            ],
            mode: .single
        )

        let result = sut.render(state: state, preferredSize: Size(rows: 30, cols: 34))
        let text = result.lines.map(\.description).joined(separator: " ")

        XCTAssert(result.lines.allSatisfy { $0.description.count <= 34 })
        XCTAssertFalse(text.contains("…"))
        XCTAssert(text.contains("title-marker"))
        XCTAssert(text.contains("help-marker"))
        XCTAssert(text.contains("[Enter]"))
    }

    func test___select_rendering___limits_wrapped_options_to_available_terminal_rows() {
        let sut = SelectComponentRenderer<String>()
        let state = SelectComponentState(
            title: "Title",
            values: [
                Selectable(title: "first-marker first-marker first-marker first-marker", value: "first"),
                Selectable(title: "second-marker second-marker second-marker second-marker", value: "second"),
                Selectable(title: "third-marker third-marker third-marker third-marker", value: "third")
            ],
            mode: .single
        )

        let result = sut.render(state: state, preferredSize: Size(rows: 15, cols: 24))

        XCTAssert(result.lines.count < 15)
        XCTAssert(result.lines.map(\.description).joined(separator: " ").contains("first-marker"))
    }
}
