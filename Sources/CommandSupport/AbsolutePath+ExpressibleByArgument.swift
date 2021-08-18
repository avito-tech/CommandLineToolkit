import ArgumentParser
import Foundation
import PathLib

extension AbsolutePath: ExpressibleByArgument {
    public convenience init?(argument: String) {
        guard argument.starts(with: "/") else { return nil }
        self.init(argument)
    }
    
    public static var defaultCompletionKind: CompletionKind = .file()
    
    public var defaultValueDescription: String { "Абсолютный путь" }
}
