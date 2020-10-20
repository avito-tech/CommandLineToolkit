import Foundation

public extension PackagePlatform {
    var statement: String {
        "." + name + "(.v" + version.replacingOccurrences(of: ".", with: "_") + ")"
    }
}
