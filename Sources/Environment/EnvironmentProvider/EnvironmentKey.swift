/// Typed env var key, allows to do correct type conversion
public struct EnvironmentKey<Value> {
    public let key: String
    public let conversion: Conversion<String, Value>
}

extension EnvironmentKey {
    public func map<NewValue>(
        _ conversion: Conversion<Value, NewValue>
    ) -> EnvironmentKey<NewValue> {
        return .init(
            key: self.key,
            conversion: self.conversion.map(conversion)
        )
    }
}

enum EnvironmentError: Error {
    case failedToTransform(value: String, type: Any.Type)
}

extension EnvironmentKey where Value == String {
    public static func string(_ key: String) -> Self {
        return .init(key: key, conversion: .identity)
    }
}

extension EnvironmentKey where Value == Int {
    public static func int(_ key: String) -> Self {
        return .init(key: key, conversion: .init(
            applyTransform: { value in
                guard let value = Int(value) else {
                    throw EnvironmentError.failedToTransform(value: value, type: Value.self)
                }
                return value
            },
            unapplyTransform: { int in
                String(int)
            }
        ))
    }
}

extension EnvironmentKey where Value == Double {
    public static func double(_ key: String) -> Self {
        return .init(key: key, conversion: .init(
            applyTransform: { value in
                guard let value = Double(value) else {
                    throw EnvironmentError.failedToTransform(value: value, type: Value.self)
                }
                return value
            },
            unapplyTransform: { double in
                String(double)
            }
        ))
    }
}

extension EnvironmentKey where Value == Bool {
    public static func bool(_ key: String) -> Self {
        return .init(key: key, conversion: .init(
            applyTransform: { value in
                switch value {
                case "true":
                    return true
                case "false":
                    return false
                default:
                    throw EnvironmentError.failedToTransform(value: value, type: Value.self)
                }
            },
            unapplyTransform: { bool in
                String(bool)
            }
        ))
    }
}

// MARK: - Common Keys

public extension EnvironmentKey where Value == String {
    /// Xcode's build script input file
    static func scriptInputFile(index: Int) -> Self {
        .string("SCRIPT_INPUT_FILE_\(index)")
    }

    /// Swiftlint config path
    static var linterConfigurationPath: Self {
        .string("LINTER_CONFIGURATION_PATH")
    }
}

public extension EnvironmentKey where Value == Int {
    /// Xcode's build script input file count
    static var scriptInputFileCount: Self {
        .int("SCRIPT_INPUT_FILE_COUNT")
    }
}

public extension EnvironmentKey where Value == Bool {
    static var isRunningOnCI: Self {
        .bool("IS_ON_BUILD_MACHINE")
    }
}
