import Logging

struct LogStreamComponentState: Hashable {
    let name: String
    var level: Logger.Level
    var renderTail: Int = 1
    var isFinished: Bool = false
    var lines: [String] = []
}
