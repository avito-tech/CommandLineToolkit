/// A single piece of `ConsoleText`. Contains a raw `String` and the desired `ConsoleStyle`.
struct ConsoleTextFragment: Equatable {
    /// The raw `String`.
    var string: String

    /// `ConsoleStyle` to use when displaying the `string`.
    var style: ConsoleStyle

    /// Creates a new `ConsoleTextFragment`.
    init(string: String, style: ConsoleStyle = .plain) {
        self.string = string
        self.style = style
    }
}
