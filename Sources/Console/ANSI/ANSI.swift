/// Terminal ANSI commands
enum ANSICommand {
    case eraseScreen
    case eraseLine
    case cursorUp
    case sgr([ANSISGRCommand])
}

/// Terminal ANSI Set Graphics Rendition (SGR) commands
enum ANSISGRCommand {
    /// Set attribute
    case attribute(ConsoleAttribute)
    /// Traditional foreground color
    case foregroundColor(UInt8)
    /// Traditional bright foreground color
    case brightForegroundColor(UInt8)
    /// Palette foreground color
    case paletteForegroundColor(UInt8)
    /// RGB "true-color" foreground color
    case rgbForegroundColor(r: UInt8, g: UInt8, b: UInt8)
    /// Keep current foreground color (effective no-op)
    case defaultForegroundColor
    /// Traditional background color
    case backgroundColor(UInt8)
    /// Traditional bright background color
    case brightBackgroundColor(UInt8)
    /// Palette background color
    case paletteBackgroundColor(UInt8)
    /// RGB "true-color" background color
    case rgbBackgroundColor(r: UInt8, g: UInt8, b: UInt8)
    /// Keep current background color (effective no-op)
    case defaultBackgroundColor
}

extension ConsoleText {
    /// Wraps a string in the ANSI codes indicated
    /// by the style specification
    func terminalStylize() -> String {
        return fragments
            .map { $0.string.terminalStylize($0.style) }
            .joined()
    }
}

extension String {
    /// Wraps a string in the ANSI codes indicated
    /// by the style specification
    func terminalStylize(_ style: ConsoleStyle) -> String {
        if style.color == nil && style.background == nil && style.attributes.isEmpty {
            return self // No style ("plain")
        }
        return style.ansiCommand.ansi +
            self +
        ANSICommand.sgr([.attribute(.normal)]).ansi
    }
}

// MARK: private

extension ANSICommand {
    /// Converts the command to its ansi code.
    fileprivate var ansi: String {
        switch self {
        case .cursorUp:
            return "1A".ansi
        case .eraseScreen:
            return "2J".ansi
        case .eraseLine:
            return "2K".ansi
        case .sgr(let subcommands):
            return (subcommands.map { $0.ansi }.joined(separator: ";") + "m").ansi
        }
    }
}

extension ANSISGRCommand {
    /// Converts the command to its ansi code.
    var ansi: String {
        switch self {
        case let .attribute(attribute):
            return "\(attribute.rawValue)"
        case let .foregroundColor(c):
            return "3\(c)"
        case let .brightForegroundColor(c):
            return "9\(c)"
        case let .paletteForegroundColor(c):
            return "38;5;\(c)"
        case let .rgbForegroundColor(r, g, b):
            return "38;2;\(r);\(g);\(b)"
        case .defaultForegroundColor:
            return "39"
        case let .backgroundColor(c):
            return "4\(c)"
        case let .brightBackgroundColor(c):
            return "10\(c)"
        case let .paletteBackgroundColor(c):
            return "48;5;\(c)"
        case let .rgbBackgroundColor(r, g, b):
            return "48;2;\(r);\(g);\(b)"
        case .defaultBackgroundColor:
            return "49"
        }
    }
}

/// This type exists for the sole purpose of encapsulating
/// the logic for distinguishing between "foreground" and "background"
/// encodings of otherwise identically-specified colors.
enum ANSISGRColorSpec {
    case traditional(UInt8)
    case bright(UInt8)
    case palette(UInt8)
    case rgb(r: UInt8, g: UInt8, b: UInt8)
    case `default`
}

extension ConsoleColor {
    /// Converts the color to the corresponding SGR color spec
    var ansiSpec: ANSISGRColorSpec {
        switch self {
        case .black:
            return .traditional(0)
        case .red:
            return .traditional(1)
        case .green:
            return .traditional(2)
        case .yellow:
            return .traditional(3)
        case .blue:
            return .traditional(4)
        case .magenta:
            return .traditional(5)
        case .cyan:
            return .traditional(6)
        case .white:
            return .traditional(7)
        case .brightBlack:
            return .bright(0)
        case .brightRed:
            return .bright(1)
        case .brightGreen:
            return .bright(2)
        case .brightYellow:
            return .bright(3)
        case .brightBlue:
            return .bright(4)
        case .brightMagenta:
            return .bright(5)
        case .brightCyan:
            return .bright(6)
        case .brightWhite:
            return .bright(7)
        case let .palette(p):
            return .palette(p)
        case let .custom(r, g, b):
            return .rgb(r: r, g: g, b: b)
        }
    }
}

extension ANSISGRColorSpec {
    /// Convert the color spec to an SGR command
    var foregroundAnsiCommand: ANSISGRCommand {
        switch self {
        case let .traditional(c):
            return .foregroundColor(c)
        case let .bright(c):
            return .brightForegroundColor(c)
        case let .palette(c):
            return .paletteForegroundColor(c)
        case let .rgb(r, g, b):
            return .rgbForegroundColor(r: r, g: g, b: b)
        case .`default`:
            return .defaultForegroundColor
        }
    }

    var backgroundAnsiCommand: ANSISGRCommand {
        switch self {
        case let .traditional(c):
            return .backgroundColor(c)
        case let .bright(c):
            return .brightBackgroundColor(c)
        case let .palette(c):
            return .paletteBackgroundColor(c)
        case let .rgb(r, g, b):
            return .rgbBackgroundColor(r: r, g: g, b: b)
        case .`default`:
            return .defaultBackgroundColor
        }
    }
}

extension ConsoleStyle {
    /// The ANSI command for this console style.
    var ansiCommand: ANSICommand {
        var commands: [ANSISGRCommand] = []

        if let color = color {
            commands.append(color.ansiSpec.foregroundAnsiCommand)
        }
        if let background = background {
            commands.append(background.ansiSpec.backgroundAnsiCommand)
        }
        commands += attributes.map(ANSISGRCommand.attribute)

        return .sgr(commands)
    }
}

extension String {
    /// Converts a String to a full ANSI command.
    fileprivate var ansi: String {
        return .CSI + self
    }
}
