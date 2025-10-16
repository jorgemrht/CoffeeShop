import Foundation

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var requiresAuth: Bool { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String:String] { get }
}


public extension APIEndpoint {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String:String] { [:] }
}
