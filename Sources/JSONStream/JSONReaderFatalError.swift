/// Describes a fatal logic error.
/// These errors should never happen in production.
/// Unit tests should cover edges cases to ensure these errors won't happen.
enum JSONReaderFatalError: Error {
    case arrayCannotHaveKeys(parent: ParsingContext, child: ParsingContext)
    case objectMustHaveKey(parent: ParsingContext, child: ParsingContext)
    case unhandledContextCombination(parent: ParsingContext, child: ParsingContext)
}
