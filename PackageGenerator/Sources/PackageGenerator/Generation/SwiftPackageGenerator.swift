import Foundation

public final class SwiftPackageGenerator {
    private let statementGenerator = StatementGenerator()
    private let directoryContainingPackageSwiftFile: URL
    
    public init(directoryContainingPackageSwiftFile: URL) {
        self.directoryContainingPackageSwiftFile = directoryContainingPackageSwiftFile
    }
    
    public func generateContents() throws -> Set<GeneratedPackageContents> {
        try statementGenerator.generatePackageSwiftCode(
            generatablePackage: try GeneratablePackage(
                location: directoryContainingPackageSwiftFile
            )
        )
    }
    
    public func assertCurrentContentsEquals(
        generatedContents: Set<GeneratedPackageContents>
    ) throws {
        for item in generatedContents {
            log("Checking if package contents at \(item.package.location.path) matches expected value")
            let currentContents = try Data(contentsOf: item.package.packageSwiftUrl)
            if currentContents != item.contents.data(using: .utf8) {
                throw ContentMismatchError(packageSwiftFileUrl: item.package.packageSwiftUrl)
            }
        }
    }
    
    public func store(generatedContents: Set<GeneratedPackageContents>) throws {
        for item in generatedContents {
            log("Storing generated package contents at \(item.package.packageSwiftUrl.path)")
            try item.contents
                .data(using: .utf8)?
                .write(to: item.package.packageSwiftUrl)
        }
    }
}

public struct ContentMismatchError: Error, CustomStringConvertible {
    let packageSwiftFileUrl: URL
    
    public var description: String {
        "Contents of \(packageSwiftFileUrl.path) differs from expected. Please re-generate it and commit changes."
    }
}
