import Foundation

private func inShellBlacklist(_ codeUnit: UInt8) -> Bool {
    switch codeUnit {
    case UInt8(ascii: "a")...UInt8(ascii: "z"),
         UInt8(ascii: "A")...UInt8(ascii: "Z"),
         UInt8(ascii: "0")...UInt8(ascii: "9"),
         UInt8(ascii: "-"),
         UInt8(ascii: "_"),
         UInt8(ascii: "/"),
         UInt8(ascii: ":"),
         UInt8(ascii: "@"),
         UInt8(ascii: "%"),
         UInt8(ascii: "+"),
         UInt8(ascii: "="),
         UInt8(ascii: "."),
         UInt8(ascii: ","):
        return false
    default:
        return true
    }
}

extension StringProtocol {
    public func shellEscaped() -> Self {
        if isEmpty {
            return "''"
        }

        if utf8.contains(where: inShellBlacklist) {
            return "'\(self.replacingOccurrences(of: "'", with: "'\\''"))'"
        }

        return self
    }
}
