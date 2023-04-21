import Foundation

extension Sequence where Element: Hashable {
    func removeDuplicates() -> [Element] {
        var deduplicationSet: Set<Element> = []

        return compactMap { element in
            let (inserted, value) = deduplicationSet.insert(element)
            return inserted ? value : nil
        }
    }
}
