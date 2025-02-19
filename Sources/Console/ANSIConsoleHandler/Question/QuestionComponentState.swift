struct QuestionComponentState: Hashable {
    enum QuestionResult: Hashable {
        case cancelled
        case selected(answer: Bool)
    }

    var title: String
    var defaultAnswer: Bool
    var help: String?
    
    private(set) var result: QuestionResult?

    mutating func cancel() {
        self.result = .cancelled
    }

    mutating func confirm(answer: Bool) {
        self.result = .selected(answer: answer)
    }
}
