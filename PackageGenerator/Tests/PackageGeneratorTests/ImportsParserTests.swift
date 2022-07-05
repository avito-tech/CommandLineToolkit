import PackageGenerator
import XCTest

final class ImportsParserTests: XCTestCase {
    func test() throws {
        XCTAssertEqual(
            try ImportsParser().getImportedModuleNames(
                sourceCode: """
                import Foundation
                import Foundation
                @testable import MyModule
                import class UIKit.UIView
                """
            ),
            ["Foundation", "MyModule", "UIKit"]
        )
    }
    
    func test___false_positives() throws {
        // expected results for valid behavior:
        // [
        //     "ValidImportButPreceedingLineComment"
        // ]
        
        let expectedResultsForCurrentBehavior: Set<String> = [
            "NotAnImportBecauseItIsWithinStringLiteral",
            "NotAnImportBecauseItIsWithinMultilineComment"
        ]
        
        // This test documents limitations (expected results are actually wrong results)
        XCTAssertEqual(
            try ImportsParser().getImportedModuleNames(
                sourceCode: #"""
                let stringLiteral = """
                import NotAnImportBecauseItIsWithinStringLiteral
                """
                /*
                import NotAnImportBecauseItIsWithinMultilineComment
                */
                
                import ValidImportButPreceedingLineComment // line comment
                """#
            ),
            expectedResultsForCurrentBehavior
        )
    }
}
