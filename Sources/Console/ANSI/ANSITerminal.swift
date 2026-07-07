#if os(macOS)
import Darwin
#else
import Glibc
#endif
import SignalHandling

extension String {
    static let ESC = "\u{1B}"  // Escape character (27 or 1B)
    static let SS2 = ESC + "N"   // Single Shift Select of G2 charset
    static let SS3 = ESC + "O"   // Single Shift Select of G3 charset
    static let DCS = ESC + "P"   // Device Control String
    static let CSI = ESC + "["   // Control Sequence Introducer
    static let OSC = ESC + "]"   // Operating System Command
    static let BACK = ESC + "b"  // Word Back
    static let FORV = ESC + "f"  // Word Forward
}

struct ANSITerminalOutput {
    let terminal: ANSITerminal
    let stream: ConsoleOutputStream

    private var stdioOutput: StdioOutputStream {
        terminal.stdioOutput(for: stream)
    }

    var isTTY: Bool {
        terminal.isTTY(outputStream: stream)
    }

    func ansiRequest(_ command: String, endChar: Character) -> String {
        terminal.ansiRequest(command, endChar: endChar, outputStream: stream)
    }

    /// Direct write to selected standard output stream
    func write(_ text: String) {
        stdioOutput.write(text)
    }

    private func write(_ text: [String]) {
        write(text.joined())
    }

    /// Direct write to selected standard output stream
    func write(_ text: String...) {
        write(text)
    }

    /// Direct write to selected standard output stream with new line
    func writeln(_ text: String...) {
        write(text + ["\n"])
    }

    /// Direct write to selected standard output stream only new line
    func writeln() {
        write("\n")
    }
}

public final class ANSITerminal {
    public static let shared: ANSITerminal = .init()

    private var terminal: termios = termios()
    private(set) var isNonBlockingMode = false
    private(set) var isNonBlockingExitSetUp = false
    var isCursorVisible = true

    private let lock: ReadWriteLock = .init()
    private(set) var size: Size = .init(rows: 0, cols: 0)

    private init() {
        size = self.getSize()

        SignalHandling.addSignalHandler(signal: .user(SIGWINCH)) { _ in
            self.lock.withWriterLockVoid {
                self.size = self.getSize()
            }
        }
    }

    /// Check key from input poll
    func keyPressed() -> Bool {
        if !isNonBlockingMode { enableNonBlockingTerminal() }
        var fds = [pollfd(fd: STDIN_FILENO, events: Int16(POLLIN), revents: 0)]
        return poll(&fds, 1, 0) > 0
    }

    /// Read key as character
    func readChar() -> Character {
        var bytes: [UInt8] = []

        while true {
            bytes.append(readByte())

            guard let str = String(bytes: bytes, encoding: .utf8) else {
                continue
            }

            guard let char = str.first else {
                continue
            }

            return char
        }
    }

    /// Read key as ascii code
    func readByte() -> UInt8 {
        var key: UInt8 = 0
        let res = read(STDIN_FILENO, &key, 1)
        return res < 0 ? 0 : key
    }

    func isTTY(outputStream: ConsoleOutputStream) -> Bool {
        switch outputStream {
        case .stdout:
            isatty(STDOUT_FILENO) > 0
        case .stderr:
            isatty(STDERR_FILENO) > 0
        }
    }

    var isInputTTY: Bool {
        isatty(STDIN_FILENO) > 0
    }

    /// Request terminal info using ansi esc command and return the response value
    func ansiRequest(
        _ command: String,
        endChar: Character,
        outputStream: ConsoleOutputStream = .stdout
    ) -> String {
        // store current input mode
        let nonBlock = isNonBlockingMode
        if !nonBlock { enableNonBlockingTerminal() }

        // send request
        stdioOutput(for: outputStream).write(command)

        // read response
        var res: String = ""
        var key: UInt8  = 0
        repeat {
            read(STDIN_FILENO, &key, 1)
            res.append(Character(UnicodeScalar(key)))
        } while key != endChar.asciiValue

        // restore input mode and return response value
        if !nonBlock { disableNonBlockingTerminal() }
        return res
    }

    /// Direct write to standard output
    func write(_ text: String) {
        stdioOutput(for: .stdout).write(text)
    }

    /// Direct write to standard output
    func write(_ text: [String]) {
        write(text.joined())
    }

    /// Direct write to standard output
    func write(_ text: String...) {
        write(text)
    }

    /// Direct write to standard output with new line
    func writeln(_ text: String...) {
        write(text + ["\n"])
    }

    /// Direct write to standard output only new line
    func writeln() {
        write("\n")
    }

    fileprivate func stdioOutput(for outputStream: ConsoleOutputStream) -> StdioOutputStream {
        switch outputStream {
        case .stdout:
            return .stdout
        case .stderr:
            return .stderr
        }
    }

    private func getSize() -> Size {
        var winsz = winsize()
        _ = ioctl(0, UInt(TIOCGWINSZ), &winsz)
        return Size(rows: Int(winsz.ws_row), cols: Int(winsz.ws_col))
    }
}

extension ANSITerminal {
    func output(to stream: ConsoleOutputStream = .stdout) -> ANSITerminalOutput {
        ANSITerminalOutput(terminal: self, stream: stream)
    }
}

// MARK: - Non Blocking

extension ANSITerminal {
    func disableNonBlockingTerminal() {
        // restore default terminal mode
        var blockTerm = terminal
        
        // enable CANONical mode and ECHO-ing input
        blockTerm.c_lflag |= tcflag_t(ICANON | ECHO | ECHOCTL)
        // acknowledge CRNL line ending and UTF8 input
        blockTerm.c_iflag |= tcflag_t(ICRNL | IUTF8)
        
        tcsetattr(STDIN_FILENO, TCSANOW, &blockTerm)
        isNonBlockingMode = false
    }

    func enableNonBlockingTerminal() {
        // store current terminal mode
        tcgetattr(STDIN_FILENO, &terminal)
        if !isNonBlockingExitSetUp {
            atexit(exitDisableNonBlockingTerminal)
            isNonBlockingExitSetUp = true
        }
        isNonBlockingMode = true

        // configure non-blocking and non-echoing terminal mode
        var nonBlockTerm = terminal
        
        // disable CANONical mode and ECHO-ing input
        nonBlockTerm.c_lflag &= ~tcflag_t(ICANON | ECHO | ECHOCTL)
        // acknowledge CRNL line ending and UTF8 input
        nonBlockTerm.c_iflag &= ~tcflag_t(ICRNL | IUTF8)

        // enable new terminal mode
        tcsetattr(STDIN_FILENO, TCSANOW, &nonBlockTerm)
    }
}

private func exitDisableNonBlockingTerminal() {
    ANSITerminal.shared.disableNonBlockingTerminal()
}
