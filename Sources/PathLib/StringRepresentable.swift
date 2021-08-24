// Like `CustomStringConvertible`, but instead of allowing
// to implement description, it requires class to represent a string,
// not something with description.
// Example: Int is integer, not a string, so it is not StringRepresentable.
// String, Substring, StaticString are all StringRepresentable.

public protocol StringRepresentable {
    var asString: String { get }
}

extension String: StringRepresentable {
    public var asString: String {
        self
    }
}

extension Substring: StringRepresentable {
    public var asString: String {
        return String(self)
    }
}

extension StaticString: StringRepresentable {
    public var asString: String {
        return String(self.description)
    }
}
