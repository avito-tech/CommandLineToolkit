extension Sequence {
    //
    // Filters sequence and put matching elements in one array and not matching elements in the other
    //
    // Usage example:
    //
    // ```
    // let (odd, even) = [1, 2, 3, 4].splitToArrays { $0 % 2 == 1 }
    // ```
    //
    public func splitToArrays(isIncludedInFirstArray: (Element) throws -> Bool) rethrows -> ([Element], [Element]) {
        try split(
            isIncludedInFirstCollection: isIncludedInFirstArray,
            createCollection: { [] },
            insertIntoCollection: { $0.append($1) }
        )
    }
    
    private func split<ProducedSequenceType: Sequence>(
        isIncludedInFirstCollection: (Element) throws -> Bool,
        createCollection: () -> ProducedSequenceType,
        insertIntoCollection: (inout ProducedSequenceType, Element) -> ()
    ) rethrows -> (ProducedSequenceType, ProducedSequenceType) where ProducedSequenceType.Element == Element {
        var matchingElements = createCollection()
        var nonMatchingElements = createCollection()
        
        try forEach { element in
            if try isIncludedInFirstCollection(element) {
                insertIntoCollection(&matchingElements, element)
            } else {
                insertIntoCollection(&nonMatchingElements, element)
            }
        }
        
        return (
            matchingElements,
            nonMatchingElements
        )
    }
}

extension Sequence where Element: Hashable {
    public func splitToSets(isIncludedInFirstSet: (Element) throws -> Bool) rethrows -> (Set<Element>, Set<Element>) {
        try split(
            isIncludedInFirstCollection: isIncludedInFirstSet,
            createCollection: { Set() },
            insertIntoCollection: { $0.insert($1) }
        )
    }
}
