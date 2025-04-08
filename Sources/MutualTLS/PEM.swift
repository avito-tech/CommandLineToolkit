import Foundation
import PathLib

struct PEM {
    struct DecodingError: Error {
        var description: String {
            "Failed to decode pem"
        }
    }

    let contents: String

    init(contents: String) {
        self.contents = contents
    }

    init(path: AbsolutePath) throws {
        self.contents = try String(contentsOfFile: path.pathString)
    }

    func asDER() throws -> DER {
        let headerRegex = #"-----(?:BEGIN|END) (?<label>(?:CERTIFICATE|RSA PRIVATE KEY))-----"#

        let derString = contents
            .replacingOccurrences(of: headerRegex, with: "", options: .regularExpression)
            .replacingOccurrences(of: "\n", with: "")

        guard let derData = Data(base64Encoded: derString) else {
            throw DecodingError()
        }

        return .init(data: derData)
    }
}

struct DER {
    let data: Data
}
