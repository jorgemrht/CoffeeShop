import Foundation

public enum AuthEndpoints: APIEndpoint {
    
    case login(email: String, password: String)
    case register

    public var path: String {
        switch self {
        case .login: return "/auth/login"
        case .register:    return "/auth/register"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .login: return .post
        case .register:    return .get
        }
    }
    
    public var requiresAuth: Bool { false }
    public var headers: [String:String] { [:] }
}
