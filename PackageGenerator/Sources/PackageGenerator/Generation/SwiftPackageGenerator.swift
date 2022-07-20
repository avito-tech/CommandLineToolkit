import Foundation

public final class SwiftPackageGenerator {
    private let statementGenerator = StatementGenerator(
        filePathResolver: FilePathResolverImpl(
            repoRootProvider: RepoRootProviderImpl()
        )
    )
    private let directoryContainingPackageSwiftFile: URL
    private let failOnStoreError: Bool
    
    public init(
        directoryContainingPackageSwiftFile: URL,
        failOnStoreError: Bool
    ) {
        self.directoryContainingPackageSwiftFile = directoryContainingPackageSwiftFile
        self.failOnStoreError = failOnStoreError
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
            let currentContents = try String(contentsOf: item.package.packageSwiftUrl)
            if currentContents != item.contents {
                throw ContentMismatchError(
                    packageSwiftFileUrl: item.package.packageSwiftUrl,
                    currentContents: currentContents,
                    generatedContents: item.contents
                )
            }
        }
    }
    
    public func store(generatedContents: Set<GeneratedPackageContents>) throws {
        var collectedErrors = [Error]()
        
        for item in generatedContents {
            log("Storing generated package contents at \(item.package.packageSwiftUrl.path)")
            do {
                try item.contents
                    .data(using: .utf8)?
                    .write(to: item.package.packageSwiftUrl)
            } catch {
                collectedErrors.append(error)
                log("ERROR: failed to write into \(item.package.packageSwiftUrl.path): \(error)")
            }
        }
        
        if failOnStoreError {
            throw StoreGenerationResultError(errors: collectedErrors)
        }
    }
}
