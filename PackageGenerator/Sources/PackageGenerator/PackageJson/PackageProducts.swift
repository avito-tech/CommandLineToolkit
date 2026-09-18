import Foundation

/// Defines what products a package exports
public enum PackageProducts: Codable, Hashable {
    
    /// Package declares a specific list of products
    case explicit([PackageProduct])
    
    /// A single product must be generated for each target
    case productForEachTarget
    
    public static let productForEachTargetStringRep = "productForEachTarget"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let stringRep = try container.decode(String.self)
            guard stringRep == PackageProducts.productForEachTargetStringRep else {
                fatalError("Must be '\(PackageProducts.productForEachTargetStringRep)'")
            }
            self = .productForEachTarget
        } catch {
            self = .explicit(try container.decode([PackageProduct].self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .productForEachTarget:
            try container.encode(PackageProducts.productForEachTargetStringRep)
        case let .explicit(value):
            try container.encode(value)
        }
    }
}
