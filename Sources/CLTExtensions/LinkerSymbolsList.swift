import Foundation
#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

/// The text format accepted by ld's -exported_symbols_list.
/// Symbol names are never demangled or interpreted as shell expressions.
public struct LinkerSymbolsList: Equatable {
    public let entries: [String]

    private let literals: Set<String>
    private let patterns: [String]

    public init(data: Data) throws {
        guard var text = String(data: data, encoding: .utf8) else {
            throw LinkerSymbolsListError("Symbols list must be UTF-8")
        }

        if text.hasPrefix("\u{FEFF}") {
            text.removeFirst()
        }

        var entries: Set<String> = []

        for (offset, rawLine) in text.components(separatedBy: .newlines).enumerated() {
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            guard !line.isEmpty, !line.hasPrefix("#") else {
                continue
            }

            guard !line.unicodeScalars.contains(where: { CharacterSet.controlCharacters.contains($0) }) else {
                throw LinkerSymbolsListError("Invalid control character on symbols-list line \(offset + 1)")
            }

            entries.insert(line)
        }

        self.entries = entries.sorted()
        self.literals = entries.filter { !Self.isPattern($0) }
        self.patterns = self.entries.filter(Self.isPattern)
    }

    public var normalizedData: Data {
        Data((entries.isEmpty ? "" : entries.joined(separator: "\n") + "\n").utf8)
    }

    public func contains(_ symbol: String) -> Bool {
        literals.contains(symbol) || patterns.contains { Self.matches(pattern: $0, symbol: symbol) }
    }

    public static func isPattern(_ entry: String) -> Bool {
        entry.contains { "*?[".contains($0) }
    }

    public static func matches(pattern: String, symbol: String) -> Bool {
        fnmatch(pattern, symbol, FNM_NOESCAPE) == 0
    }
}

private struct LinkerSymbolsListError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}
