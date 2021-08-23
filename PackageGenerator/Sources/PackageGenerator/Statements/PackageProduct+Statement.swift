import Foundation

public extension PackageProduct {
    var statement: String {
        let joinedTargets = targets.map { "\"\($0)\"" }.joined(separator: ", ")
        var result = "." + productType.spmProductTypeEnumCase
        result += "(name: \"\(name)\", "
        
        if let spmLibraryTypeCase = productType.spmLibraryTypeCase {
            result += "type: ." + spmLibraryTypeCase + ", "
        }
        
        result += "targets: [\(joinedTargets)])"
        return result
    }
}

private extension PackageProductType {
    var spmProductTypeEnumCase: String {
        switch self {
        case .executable:
            return "executable"
        case .dynamicLibrary, .library:
            return "library"
        }
    }
    
    var spmLibraryTypeCase: String? {
        switch self {
        case .executable:
            return nil
        case .dynamicLibrary:
            return "dynamic"
        case .library:
            return nil
        }
    }
}
