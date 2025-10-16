import Foundation

public enum ShopEndpoints: APIEndpoint {
    
    case shops
    case detail(id: Int)

    public var path: String {
        switch self {
        case .shops: "/shops"
        case .detail(let id): "/shops/\(id)"
        }
    }
    
    public var method: HTTPMethod { .get }
    public var requiresAuth: Bool { true }
    
    public var queryItems: [URLQueryItem] {
        switch self {
        case .shops: []
        case .detail: []
        }
    }
}
