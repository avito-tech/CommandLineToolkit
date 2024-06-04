import Logging

extension Logger {
    public init<Target>(for type: Target.Type) {
        let label = String(describing: type)
        self.init(label: label)
    }
}
