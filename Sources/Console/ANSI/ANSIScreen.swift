// Reference: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html

enum CursorStyle: UInt8 {
    case block = 1
    case line  = 3
    case bar   = 5
}

extension ANSITerminal {
    func setCursorStyle(_ style: CursorStyle, blinking: Bool = true) {
        if blinking {
            write(.CSI, "\(style.rawValue) q")
        } else {
            write(.CSI, "\(style.rawValue + 1) q")
        }
    }

    func storeCursorPosition(isANSI: Bool = false) {
        if isANSI { write(.CSI, "s") } else { write(.ESC, "7") }
    }

    func restoreCursorPosition(isANSI: Bool = false) {
        if isANSI { write(.CSI, "u") } else { write(.ESC, "8") }
    }

    func enableInverted() {
        write(.CSI, "7m")
    }

    func disableInverted() {
        write(.CSI, "27m")
    }

    func enableAlternateBuffer() {
        write(.CSI, "?1049h")
    }

    func disableAlternateBuffer() {
        write(.CSI, "?1049l")
    }

    func clearBelow() {
        write(.CSI, "0J")
    }

    func clearAbove() {
        write(.CSI, "1J")
    }

    func clearScreen() {
        write(.CSI, "2J", .CSI, "H")
    }

    func clearToEndOfLine() {
        write(.CSI, "0K")
    }

    func clearToStartOfLine() {
        write(.CSI, "1K")
    }

    func clearLine() {
        write(.CSI, "2K")
    }

    func scrollUp(row: Int = 1) {
        write(.CSI, "\(row)^")
    }

    func moveUp(_ row: Int = 1) {
        write(.CSI, "\(row)A")
    }

    func moveDown(_ row: Int = 1) {
        write(.CSI, "\(row)B")
    }

    func moveRight(_ col: Int = 1) {
        write(.CSI, "\(col)C")
    }

    func moveLeft(_ col: Int = 1) {
        write(.CSI, "\(col)D")
    }

    func moveLineDown(_ row: Int = 1) {
        write(.CSI, "\(row)E")
    }

    func moveLineUp(_ row: Int = 1) {
        write(.CSI, "\(row)F")
    }

    func moveToColumn(_ col: Int) {
        write(.CSI, "\(col)G")
    }

    func moveTo(_ row: Int, _ col: Int) {
        write(.CSI, "\(row);\(col)H")
    }

    func insertLine(_ row: Int = 1) {
        write(.CSI, "\(row)L")
    }

    func deleteLine(_ row: Int = 1) {
        write(.CSI, "\(row)M")
    }

    func deleteChar(_ char: Int = 1) {
        write(.CSI, "\(char)P")
    }

    func cursorOff() {
        write(.CSI, "?25l")
        isCursorVisible = false
    }

    func cursorOn() {
        write(.CSI, "?25h")
        isCursorVisible = true
    }

    // swiftlint:disable force_unwrapping

    func readCursorPos() -> Position {
        let str = ansiRequest(.CSI + "6n", endChar: "R")  // returns ^[row;colR
        if str.isEmpty { return .init(row: -1, col: -1) }

        let esc = str.firstIndex(of: "[")!
        let del = str.firstIndex(of: ";")!
        let end = str.firstIndex(of: "R")!
        let row = String(str[str.index(after: esc)...str.index(before: del)])
        let col = String(str[str.index(after: del)...str.index(before: end)])

        return .init(row: Int(row)!, col: Int(col)!)
    }

    // swiftlint:enable force_unwrapping
}
