extension SetAlgebra {
    @inlinable public func intersects(with other: Self) -> Bool {
        !isDisjoint(with: other)
    }
}
