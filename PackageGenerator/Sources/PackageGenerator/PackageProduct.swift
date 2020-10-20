import Foundation

/// Describes a product
public struct PackageProduct: Codable, Equatable {
    
    public enum ProductType: String, Codable {
        case executable
        case library
    }
    
    /// Name of the product
    public let name: String
    
    /// Type of the product
    public let productType: ProductType
    
    /// Name of the targets this product consists of.
    public let targets: [String]
    
    public init(name: String, productType: PackageProduct.ProductType, targets: [String]) {
        self.name = name
        self.productType = productType
        self.targets = targets
    }
}
