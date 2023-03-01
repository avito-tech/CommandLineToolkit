import Foundation

extension Collection {
    public func single(where matcher: (Element) -> (Bool) = { _ in true }) throws -> Element {
        let filtered = self.filter(matcher)
        guard !filtered.isEmpty else {
            throw "Didn't find a single matching element in: \(self) of type \(type(of: self))"
        }
        guard filtered.count == 1 else {
            throw "Found more than one matching element: \(filtered)"
        }
        return filtered[0]
    }
}
