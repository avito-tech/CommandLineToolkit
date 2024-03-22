import Foundation
import XCTest
@testable import PackageGenerator

extension XCTestCase {
    var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
        return encoder
    }
    var jsonDecoder: JSONDecoder {
        JSONDecoder()
    }
    
    func assert<JsonFile: Codable & Equatable>(
        jsonFile: JsonFile,
        equalsJsonRepresentation: String
    ) throws {
        let parsedFile = try jsonDecoder.decodeExplaining(
            JsonFile.self,
            from: Data(equalsJsonRepresentation.utf8)
        )
        if jsonFile != parsedFile {
            let json = try jsonEncoder.encode(jsonFile)
            record(
                XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "Invalid JSON representation",
                    detailedDescription: String(data: json, encoding: .utf8),
                    attachments: [XCTAttachment(data: json, uniformTypeIdentifier: "public.json")]
                )
            )
        }
    }
}
