import FileSystem
import Foundation
import PathLib
import ProcessController

public final class ClocTool: Cloc {
    private let filePropertiesProvider: FilePropertiesProvider
    private let processControllerProvider: ProcessControllerProvider
    
    private struct ClocOutput: Codable, CustomStringConvertible {
        struct SUM: Codable {
            let code: Int
        }
        
        let SUM: SUM
        
        var description: String {
            "sum.code=\(self.SUM.code)"
        }
    }
    
    public init(
        filePropertiesProvider: FilePropertiesProvider,
        processControllerProvider: ProcessControllerProvider
    ) {
        self.filePropertiesProvider = filePropertiesProvider
        self.processControllerProvider = processControllerProvider
    }
    
    private let clocBinaryPaths = [
        AbsolutePath("/usr/local/bin/cloc"),
        AbsolutePath("/opt/homebrew/bin/cloc"),
    ]
    
    public func countLinesOfCode(
        sourceFiles: [AbsolutePath]
    ) throws -> Int {
        for clocBinaryPath in clocBinaryPaths {
            if !filePropertiesProvider.exists(path: clocBinaryPath) {
                continue
            }
            
            if try filePropertiesProvider.properties(path: clocBinaryPath).isExecutable {
                return try run(
                    clocBinaryPath: clocBinaryPath,
                    sourceFiles: sourceFiles
                )
            }
        }
        
        throw "Could not locate cloc binary"
    }
    
    private func run(
        clocBinaryPath: AbsolutePath,
        sourceFiles: [AbsolutePath]
    ) throws -> Int {
        let processController = try processControllerProvider.createProcessController(
            subprocess: Subprocess(
                arguments: [
                    clocBinaryPath,
                    "--json",
                    "--include-lang=swift",
                ] + sourceFiles
            )
        )
        var clocOutput = Data()
        processController.onStdout { _, data, _ in clocOutput.append(contentsOf: data) }
        try processController.startAndWaitForSuccessfulTermination()
        
        let parsedOutput = try JSONDecoder().decode(ClocOutput.self, from: clocOutput)
        return parsedOutput.SUM.code
    }
}
