public enum FileExistence {
    case isFile
    case isDirectory
    case doesntExist
    
    public var exists: Bool {
        return self != .doesntExist
    }
    
    public var isFile: Bool {
        return self == .isFile
    }
    
    public var isDirectory: Bool {
        return self == .isDirectory
    }
}
