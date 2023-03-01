// Comparison operators for Boolean (note that from a logical point of view `<` makes no sense for boolean values)
extension Bool {
    // false, false -> false
    // false, true  -> true
    // true, false  -> false
    // true, true   -> false
    public static func isOrderedFromFalseToTrue(_ lhs: Bool, _ rhs: Bool) -> Bool {
        return !lhs && rhs
    }
    
    // false, false -> false
    // false, true  -> false
    // true, false  -> true
    // true, true   -> false
    public static func isOrderedFromTrueToFalse(_ lhs: Bool, _ rhs: Bool) -> Bool {
        return lhs && !rhs
    }
}
