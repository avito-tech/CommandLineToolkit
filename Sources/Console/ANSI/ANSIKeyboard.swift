enum ANSIKeyCode: UInt8 {
    case none      = 0    // null
    case up        = 65   // ESC [ A
    case down      = 66   // ESC [ B
    case right     = 67   // ESC [ C
    case left      = 68   // ESC [ D
    case end       = 70   // ESC [ F  or  ESC [ 4~
    case home      = 72   // ESC [ H  or  ESC [ 1~
    case insert    = 2    // ESC [ 2~
    case delete    = 3    // ESC [ 3~
    case pageUp    = 5    // ESC [ 5~
    case pageDown  = 6    // ESC [ 6~
    
    case f1        = 80   // ESC O P  or  ESC [ 11~
    case f2        = 81   // ESC O Q  or  ESC [ 12~
    case f3        = 82   // ESC O R  or  ESC [ 13~
    case f4        = 83   // ESC O S  or  ESC [ 14~
    case f5        = 15   // ESC [ 15~
    case f6        = 17   // ESC [ 17~
    case f7        = 18   // ESC [ 18~
    case f8        = 19   // ESC [ 19~
    case f9        = 20   // ESC [ 20~
    case f10       = 21   // ESC [ 21~
    case f11       = 23   // ESC [ 23~
    case f12       = 24   // ESC [ 24~
}

enum ANSIMetaCode: UInt8 {
    case control = 1
    case shift   = 2
    case alt     = 3
}

struct Position: Hashable {
    var row: Int
    var col: Int
}

struct Size: Hashable {
    var rows: Int
    var cols: Int
}

extension Size {
    static let max: Size = .init(rows: .max, cols: .max)
}

enum InputEscapeSequence {
    case key(code: ANSIKeyCode, meta: [ANSIMetaCode])
    case cursor(position: Position)
    case screen(size: Size)
    case unknown(raw: String)
}

private func SS3Letter(_ key: UInt8) -> ANSIKeyCode {
    switch key {
    case ANSIKeyCode.f1.rawValue:
        return .f1
    case ANSIKeyCode.f2.rawValue:
        return .f2
    case ANSIKeyCode.f3.rawValue:
        return .f3
    case ANSIKeyCode.f4.rawValue:
        return .f4
    default:
        return .none
    }
}

private func CSILetter(_ key: UInt8) -> ANSIKeyCode {
    switch key {
    case ANSIKeyCode.up.rawValue:
        return .up
    case ANSIKeyCode.down.rawValue:
        return .down
    case ANSIKeyCode.left.rawValue:
        return .left
    case ANSIKeyCode.right.rawValue:
        return .right
    case ANSIKeyCode.home.rawValue:
        return .home
    case ANSIKeyCode.end.rawValue:
        return .end
    case ANSIKeyCode.f1.rawValue:
        return .f1
    case ANSIKeyCode.f2.rawValue:
        return .f2
    case ANSIKeyCode.f3.rawValue:
        return .f3
    case ANSIKeyCode.f4.rawValue:
        return .f4
    default:
        return .none
    }
}

private func CSINumber(_ key: UInt8) -> ANSIKeyCode {
    switch key {
    case 1:
        return .home
    case 4:
        return .end
    case ANSIKeyCode.insert.rawValue:
        return .insert
    case ANSIKeyCode.delete.rawValue:
        return .delete
    case ANSIKeyCode.pageUp.rawValue:
        return .pageUp
    case ANSIKeyCode.pageDown.rawValue:
        return .pageDown
    case 11:
        return .f1
    case 12:
        return .f2
    case 13:
        return .f3
    case 14:
        return .f4
    case ANSIKeyCode.f5.rawValue:
        return .f5
    case ANSIKeyCode.f6.rawValue:
        return .f6
    case ANSIKeyCode.f7.rawValue:
        return .f7
    case ANSIKeyCode.f8.rawValue:
        return .f8
    case ANSIKeyCode.f9.rawValue:
        return .f9
    case ANSIKeyCode.f10.rawValue:
        return .f10
    case ANSIKeyCode.f11.rawValue:
        return .f11
    case ANSIKeyCode.f12.rawValue:
        return .f12
    default:
        return .none
    }
}

private extension FixedWidthInteger {
    var isLetter: Bool {
        return (65...90 ~= self)
    }

    var isNumber: Bool {
        return (48...57 ~= self)
    }
}

private extension UInt8 {
    var char: Character {
        .init(.init(self))
    }
}

extension Character {
    static let none: Self      = "\u{00}"   // \0 NUL
    static let bell: Self      = "\u{07}"   // \a BELL
    static let erase: Self     = "\u{08}"   // BS
    static let tab: Self       = "\u{09}"   // \t TAB (horizontal)
    static let linefeed: Self  = "\u{0A}"   // \n LF
    static let vtab: Self      = "\u{0B}"   // \v VT (vertical tab)
    static let formfeed: Self  = "\u{0C}"   // \f FF
    static let enter: Self     = "\u{0D}"   // \r CR
    static let endOfLine: Self = "\u{1A}"   // SUB or EOL
    static let escape: Self    = "\u{1B}"   // \e ESC
    static let space: Self     = "\u{20}"   // SPACE
    static let del: Self       = "\u{7F}"   // DEL

    var isNonPrintable: Bool {
        return self < " " || self == "\u{7F}"
    }
}

private func CSIMeta(_ key: UInt8) -> [ANSIMetaCode] {
    //! NOTE: if x = 1 then ~ becomes letter
    switch key {
    case 2:
        return [.shift]                     // ESC [ x ; 2~
    case 3:
        return [.alt]                       // ESC [ x ; 3~
    case 4:
        return [.shift, .alt]               // ESC [ x ; 4~
    case 5:
        return [.control]                   // ESC [ x ; 5~
    case 6:
        return [.shift, .control]           // ESC [ x ; 6~
    case 7:
        return [.alt, .control]             // ESC [ x ; 7~
    case 8:
        return [.shift, .alt, .control]     // ESC [ x ; 8~
    default:
        return []
    }
}

extension ANSITerminal {
    func readEscapeSequence() -> InputEscapeSequence {
        let nonBlock = isNonBlockingMode
        if !nonBlock { enableNonBlockingTerminal() }
        defer {
            if !nonBlock { disableNonBlockingTerminal() }
        }

        var code = ANSIKeyCode.none

        var byte: UInt8 = 0
        var cmd: String = .ESC

        func readNextByte() {
            byte = readByte()
            cmd.append(byte.char)
        }

        func readNumber(beginning: String = "") -> UInt8 {
            var numberString = beginning
            repeat {
                readNextByte()
                if byte.isNumber { numberString.append(byte.char) }
            } while byte.isNumber
            return UInt8(numberString) ?? 0
        }

        // make sure there is data in stdin
        if !keyPressed() { return .unknown(raw: cmd) }

        while true {                                // read key sequence
            cmd.append(readChar())                  // check for ESC combination

            switch cmd {
            case .CSI:
                readNextByte()

                if byte.isLetter {                              // CSI + letter
                    code = CSILetter(byte)
                    return .key(code: code, meta: [])
                } else if byte.isNumber {                       // CSI + numbers
                    let firstNumber = readNumber(beginning: .init(byte.char))

                    switch byte.char {
                    case "~":
                        code = CSINumber(UInt8(firstNumber))
                        return .key(code: code, meta: [])
                    case ";":
                        let secondNumber = readNumber()

                        switch byte.char {
                        case "~":
                            return .key(code: CSINumber(firstNumber), meta: CSIMeta(secondNumber))
                        case "R":
                            return .cursor(position: Position(
                                row: Int(firstNumber),
                                col: Int(secondNumber)
                            ))
                        case ";":
                            let thirdNumber = readNumber()

                            switch byte.char {
                            case "t" where firstNumber == 8:
                                return .screen(size: .init(rows: Int(secondNumber), cols: Int(thirdNumber)))
                            default:
                                return .unknown(raw: cmd)
                            }

                        default:
                            return .key(code: CSILetter(byte), meta: CSIMeta(secondNumber))
                        }
                    default:
                        return .unknown(raw: cmd)
                    }
                } else {
                    // neither letter nor numbers
                    break
                }
            case .SS3:
                readNextByte()
                if byte.isLetter { code = SS3Letter(byte) }
                return .key(code: code, meta: [])
            case .BACK:
                return .key(code: .left, meta: [.alt])
            case .FORV:
                return .key(code: .right, meta: [.alt])
            default:
                return .unknown(raw: cmd)
            }
        }
    }
}
