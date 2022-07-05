import Foundation

public final class ImportsParser {
    private let importStatementRegex: NSRegularExpression
    
    public init() throws {
        // https://docs.swift.org/swift-book/ReferenceManual/Declarations.html#grammar_import-declaration
        let anyWhitespace = #"\s*"#
        let whitespace = #"\s+"#
        let attributesRegex = "@testable"
        let importKindRegex = "(?:typealias|struct|class|enum|protocol|let|var|func)"
        let importPathRegex = #"\S+(?:\.\S+)*"# // "ModuleName" or "ModuleName.ClassName" or with longer path
        
        func group(_ pattern: String) -> String {
            return "(\(pattern))"
        }
        func optionalGroup(_ pattern: String) -> String {
            return "\(group(pattern))?"
        }
        
        /// NOTE: Whitespaces at the beginning of lines are not supported.
        /// This is due to possibility of such statements:
        ///
        /// ```
        /// import ValidImport
        ///
        /// let string = """
        ///     import NotAnImportBecauseIsInsideStringLiteral
        ///     """
        /// ```
        ///
        /// Note that this is a workaround, because this code will still produce false positives:
        ///
        /// ```
        /// import ValidImport
        ///
        /// let string = """
        /// import WithoutWhitespacesPriorToImportKeyword
        /// """
        /// ```
        ///
        /// A proper Swift parser is needed to cover all edge-cases.
        ///
        self.importStatementRegex = try NSRegularExpression(
            pattern: [
                "^", // start of the line
                optionalGroup("\(attributesRegex)\(whitespace)"), // e.g.: "@testable"
                "import\(whitespace)",
                optionalGroup("\(importKindRegex)\(whitespace)"),  // e.g.: "class" in "import class UIKit.UIView"
                group(importPathRegex), // e.g.: "UIKit.UIView" in "import class UIKit.UIView"
                "$" // end of the line
            ].joined(),
            options: [.anchorsMatchLines]
        )
    }
    
    /// ```
    /// getImportedModuleNames(
    ///     sourceCode: """
    ///     import Foundation
    ///     import Foundation
    ///     @testable import MyModule
    ///     import class UIKit.UIView
    ///     """
    /// ) == ["Foundation", "MyModule", "UIKit"]
    /// ```
    public func getImportedModuleNames(
        sourceCode: String
    ) -> Set<String> {
        var importedModuleNames: Set<String> = []
        
        let lines = sourceCode
            .split(separator: "\n")
            .filter { !$0.starts(with: "//") }
        
        for line in lines {
            let matches = importStatementRegex.matches(
                in: String(line),
                options: [],
                range: NSRange(
                    location: 0,
                    length: line.count
                )
            )
            
            guard matches.count == 1 else {
                continue
            }
            
            let importPathGroupIndex = 3
            let importPath = (line as NSString).substring(
                with: matches[0].range(
                    at: importPathGroupIndex
                )
            )
            
            // "ModuleName.ClassName" -> "ModuleName"
            guard let moduleName = importPath.split(
                separator: ".",
                maxSplits: 1,
                omittingEmptySubsequences: false
            ).first else {
                continue
            }
            
            importedModuleNames.insert(String(moduleName))
        }
        
        return importedModuleNames
    }
}
