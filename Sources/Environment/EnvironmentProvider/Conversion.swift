public struct Conversion<Input, Output> {
    private let applyTransform: (Input) throws -> Output
    private let unapplyTransform: (Output) throws -> Input

    public init(
        applyTransform: @escaping (Input) throws -> Output,
        unapplyTransform: @escaping (Output) throws -> Input
    ) {
        self.applyTransform = applyTransform
        self.unapplyTransform = unapplyTransform
    }

    public func apply(_ input: Input) throws -> Output {
        try self.applyTransform(input)
    }

    public func unapply(_ output: Output) throws -> Input {
        try self.unapplyTransform(output)
    }
}

extension Conversion {
    public func map<NewOutput>(
        _ conversion: Conversion<Output, NewOutput>
    ) -> Conversion<Input, NewOutput> {
        .init { input in
            try conversion.apply(self.apply(input))
        } unapplyTransform: { newOutput in
            try self.unapply(conversion.unapply(newOutput))
        }
    }
}

extension Conversion where Input == Output {
    static var identity: Self {
        .init { $0 } unapplyTransform: { $0 }
    }
}
