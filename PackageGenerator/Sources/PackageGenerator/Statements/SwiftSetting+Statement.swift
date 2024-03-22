import Foundation

extension SwiftSettings {
    var statements: [String] {
        map(\.statement)
    }
}

extension SwiftSetting {
    var statement: String {
        switch self {
        case let .define(name: name):
            #".define("\#(name)")"#
        case let .unsafeFlags(flags: flags):
            #".unsafeFlags([\#(flags.map({ "\"\($0)\"" }).joined(separator: ", "))])"#
        case let .enableExperimentalFeature(name: name):
            #".enableExperimentalFeature("\#(name)")"#
        case let .enableUpcomingFeature(name: name):
            #".enableUpcomingFeature("\#(name)")"#
        case let .interoperabilityMode(mode: mode):
            #".interoperabilityMode(.\#(mode.rawValue))"#
        }
    }
}
