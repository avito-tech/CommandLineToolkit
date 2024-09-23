extension String {
    /// Converts this `String` to `ConsoleText`.
    ///
    ///     console.output("Hello, " + "world!".consoleText(color: .green))
    ///
    /// See `ConsoleStyle` for more information.
    func consoleText(_ style: ConsoleStyle = .plain) -> ConsoleText {
        return [ConsoleTextFragment(string: self, style: style)]
    }

    /// Converts this `String` to `ConsoleText`.
    ///
    ///     console.output("Hello, " + "world!".consoleText(color: .green))
    ///
    /// See `ConsoleStyle` for more information.
    func consoleText(color: ConsoleColor? = nil, background: ConsoleColor? = nil, attributes: [ConsoleAttribute] = []) -> ConsoleText {
        let style = ConsoleStyle(color: color, background: background, attributes: attributes)
        return consoleText(style)
    }
}

/// A collection of `ConsoleTextFragment`s. Represents stylized text that can be outputted
/// to a `Console`.
///
///     let text: ConsoleText = "Hello, " + "world".consoleText(color: .green)
///
struct ConsoleText: RandomAccessCollection, ExpressibleByArrayLiteral, ExpressibleByStringLiteral, CustomStringConvertible, Equatable {
    /// See `Collection`.
    var startIndex: Int {
        return fragments.startIndex
    }

    /// See `Collection`.
    var endIndex: Int {
        return fragments.endIndex
    }

    /// See `Collection`.
    func index(after i: Int) -> Int {
        return i + 1
    }

    /// See `CustomStringConvertible`.
    var description: String {
        return fragments.map { $0.string }.joined()
    }

    /// See `ExpressibleByArrayLiteral`.
    init(arrayLiteral elements: ConsoleTextFragment...) {
        self.fragments = elements
    }

    /// See `ExpressibleByStringLiteral`.
    init(stringLiteral string: String) {
        if string.isEmpty {
            self.fragments = []
        } else {
            self.fragments = [.init(string: string)]
        }
    }

    /// One or more `ConsoleTextFragment`s making up this `ConsoleText.
    var fragments: [ConsoleTextFragment]

    /// Creates a new `ConsoleText`.
    init(fragments: [ConsoleTextFragment]) {
        self.fragments = fragments
    }

    /// See `Collection`.
    subscript(position: Int) -> ConsoleTextFragment {
        return fragments[position]
    }

    /// `\n` character with plain styling.
    static let newLine: ConsoleText = "\n"
}

extension ConsoleText {
    /// Trims text to specific length
    /// - Parameter length: line length
    /// - Returns: trimmed text
    func trimmed(to length: Int) -> Self {
        var remainingLength = length
        let newFragments: [ConsoleTextFragment] = fragments.compactMap { fragment in
            if fragment.string.count > remainingLength {
                if remainingLength > 0 {
                    let stringPart = String(fragment.string.prefix(remainingLength - 1))
                    remainingLength = 0
                    return .init(string: stringPart + "…", style: fragment.style)
                } else {
                    return nil
                }
            } else {
                remainingLength -= fragment.string.count
                return fragment
            }
        }

        return .init(fragments: newFragments)
    }
}

// MARK: Operators

extension ConsoleText {
    /// Appends a `ConsoleText` to another `ConsoleText`.
    ///
    ///     let text: ConsoleText = "Hello, " + "world!"
    ///
    static func +(lhs: ConsoleText, rhs: ConsoleText) -> ConsoleText {
        return ConsoleText(fragments: lhs.fragments + rhs.fragments)
    }

    /// Appends a `ConsoleText` to another `ConsoleText` in-place.
    ///
    ///     var text: ConsoleText = "Hello, "
    ///     text += "world!"
    ///
    static func +=(lhs: inout ConsoleText, rhs: ConsoleText) {
        lhs = lhs + rhs
    }
}

extension ConsoleText: ExpressibleByStringInterpolation {
    init(stringInterpolation: StringInterpolation) {
        self.fragments = stringInterpolation.fragments
    }

    struct StringInterpolation: StringInterpolationProtocol {
        var fragments: [ConsoleTextFragment]

        init(literalCapacity: Int, interpolationCount: Int) {
            self.fragments = []
            self.fragments.reserveCapacity(literalCapacity)
        }

        mutating func appendLiteral(_ literal: String) {
            self.fragments.append(.init(string: literal))
        }

        mutating func appendInterpolation(
            _ value: String,
            style: ConsoleStyle = .plain
        ) {
            self.fragments.append(.init(string: value, style: style))
        }
        
        mutating func appendInterpolation(
            _ value: Substring,
            style: ConsoleStyle = .plain
        ) {
            appendInterpolation(String(value), style: style)
        }
        
        mutating func appendInterpolation(
            _ value: String,
            color: ConsoleColor?,
            background: ConsoleColor? = nil,
            attributes: [ConsoleAttribute] = []
        ) {
            self.fragments.append(.init(string: value, style: .init(
                color: color,
                background: background,
                attributes: attributes
            )))
        }

        mutating func appendInterpolation(
            _ value: ConsoleTextFragment
        ) {
            self.fragments.append(value)
        }

        mutating func appendInterpolation(
            _ value: ConsoleText
        ) {
            self.fragments.append(contentsOf: value.fragments)
        }
    }
}
