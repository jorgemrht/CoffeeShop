import Foundation

public enum ShopEndpoints {
    
    case shops
    case detail(id: Int)

    public var endpoint: APIEndpoint {
        switch self {
        case .shops:
            APIEndpoint(
                path: "/shops",
                method: .GET,
                queryItems: nil,
                body: nil
            )

        case .detail(let id):
            APIEndpoint(
                path: "/shops/\(id)",
                method: .POST,
                queryItems: nil,
                body: nil
            )
        }
    }
}
