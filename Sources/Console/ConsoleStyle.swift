enum ConsoleAttribute: Int, Equatable {
    case normal         = 0
    case bold           = 1
    case dim            = 2
    case italic         = 3
    case underline      = 4
    case blink          = 5
    case overline       = 6
    case inverse        = 7
    case hidden         = 8
    case strike         = 9
    case noBold         = 21
    case noDim          = 22
    case noItalic       = 23
    case noUnderline    = 24
    case noBlink        = 25
    case noOverline     = 26
    case noInverse      = 27
    case noHidden       = 28
    case noStrike       = 29
}

/// Representation of a style for outputting to a Console in different colors with differing attributes.
/// A few suggested default styles are provided.
struct ConsoleStyle: Equatable {
    /// Optional text color. If `nil`, text is plain.
    let color: ConsoleColor?

    /// Optional background color. If `nil` background is plain.
    let background: ConsoleColor?

    /// If `true`, text is bold.
    let attributes: [ConsoleAttribute]

    /// Creates a new `ConsoleStyle`.
    init(
        color: ConsoleColor? = nil,
        background: ConsoleColor? = nil,
        attributes: [ConsoleAttribute] = []
    ) {
        self.color = color
        self.background = background
        self.attributes = attributes
    }
}

extension ConsoleStyle {
    /// Plain text with no color or background.
    static let plain: ConsoleStyle = .init()

    /// Green text with no background.
    static let success: ConsoleStyle = .init(
        color: .palette(28),
        attributes: [.bold]
    )

    /// Light blue text with no background.
    static var info: ConsoleStyle = .init(
        color: .palette(36)
    )

    /// Light blue text with no background.
    static var notice: ConsoleStyle = .init(
        color: .palette(36),
        attributes: [.bold]
    )

    /// Yellow text with no background.
    static var warning: ConsoleStyle = .init(
        color: .palette(214),
        attributes: [.bold]
    )

    /// Red text with no background.
    static var error: ConsoleStyle = .init(
        color: .palette(9/*196*/),
        attributes: [.bold]
    )

    static let headerTitle: ConsoleStyle = .init(
        attributes: [.bold]
    )

    static var help: ConsoleStyle = .init(
        color: .palette(180),
        attributes: [.italic]
    )
}
