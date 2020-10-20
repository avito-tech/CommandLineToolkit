import Foundation

public extension PackageDependencies {
    var statements: [String] {
        external.sorted { left, right -> Bool in
            left.key < right.key
        }
        .map { (name: String, value: ExternalPackageLocation) -> String in
            switch value {
            case let .url(url, version, _):
                return ".package(url: \"\(url)\", \(version.statement))"
            case let .local(path, _):
                return ".package(name: \"\(name)\", path: \"\(path)\")"
            }
        }
    }
}
