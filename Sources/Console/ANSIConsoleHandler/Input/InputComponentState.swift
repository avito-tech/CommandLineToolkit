/// State of input component
struct InputComponentState: Hashable {
    var title: String
    var input: String = ""
    var defaultValue: String?
    var isFinished: Bool = false
    var cursorIndex: Int = 0
}
