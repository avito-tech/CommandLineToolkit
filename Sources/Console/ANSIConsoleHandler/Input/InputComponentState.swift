/// State of input component
struct InputComponentState: Hashable {
    enum InputResult: Hashable {
        case cancelled
        case success(input: String)
    }

    var title: String
    var input: String = ""
    var defaultValue: String?
    var cursorIndex: Int = 0
    
    private(set) var result: InputResult?

    mutating func cancel() {
        self.result = .cancelled
    }

    mutating func confirm() {
        self.result = .success(input: input)
    }
}
