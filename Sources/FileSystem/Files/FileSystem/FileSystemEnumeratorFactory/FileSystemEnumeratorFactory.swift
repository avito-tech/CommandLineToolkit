import PathLib

public protocol FileSystemEnumeratorFactory {
    func contentEnumerator(forPath: AbsolutePath, style: ContentEnumerationStyle) -> FileSystemEnumerator
    func glob(pattern: GlobPattern) -> FileSystemEnumerator
}
