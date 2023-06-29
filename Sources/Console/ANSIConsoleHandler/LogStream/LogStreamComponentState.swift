import Logging

struct LogStreamComponentState: Hashable {
    let name: String
    var level: Logger.Level
    var isFinished: Bool = false
    var lines: [String] = []
}
