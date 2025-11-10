import Foundation

public enum CoffeeEndpoints {

    case list
    case detail(id: Int)

    public var endpoint: APIEndpoint {
        switch self {
        case .list:
            APIEndpoint(
                path: "/coffees",
                method: .GET,
                queryItems: nil,
                body: nil
            )

        case let .detail(id):
            APIEndpoint(
                path: "/coffees/\(id)",
                method: .GET,
                queryItems: nil,
                body: nil
            )
        }
    }
}
