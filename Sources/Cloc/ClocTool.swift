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
        sourceFiles: [AbsolutePath],
        includeLangOptions: Set<IncludeLangOption>
    ) throws -> Int {
        for clocBinaryPath in clocBinaryPaths {
            if !filePropertiesProvider.exists(path: clocBinaryPath) {
                continue
            }
            
            if try filePropertiesProvider.properties(path: clocBinaryPath).isExecutable {
                return try run(
                    clocBinaryPath: clocBinaryPath,
                    sourceFiles: sourceFiles,
                    includeLangOptions: includeLangOptions
                )
            }
        }
        
        throw "Could not locate cloc binary"
    }
    
    private func run(
        clocBinaryPath: AbsolutePath,
        sourceFiles: [AbsolutePath],
        includeLangOptions: Set<IncludeLangOption>
    ) throws -> Int {
        do {
            let processController = try processControllerProvider.createProcessController(
                subprocess: Subprocess(
                    arguments: [
                        clocBinaryPath,
                        "--json",
                        "--include-lang=\(includeLangOptions.map(\.rawValue).joined(separator: ","))"
                    ] + sourceFiles
                )
            )
            var clocOutput = Data()
            processController.onStdout { _, data, _ in clocOutput.append(contentsOf: data) }

            try processController.startAndWaitForSuccessfulTermination()

            if let parsedOutput = try? JSONDecoder().decode(ClocOutput.self, from: clocOutput) {
                return parsedOutput.SUM.code
            } else {
                return 0
            }
        } catch {
            throw """
            Failed to get cloc
            from \(sourceFiles)
            using \(clocBinaryPath)
            for \(includeLangOptions)
            becasue of \(error)
            """
        }
    }
}
