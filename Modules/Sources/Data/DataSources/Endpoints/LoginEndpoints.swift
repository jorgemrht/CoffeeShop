import Foundation

public enum LoginEndpoints {
    
    case login(email: String, password: String)
    case register(email: String, password: String)

    public var endpoint: APIEndpoint {
        switch self {
        case let .login(email, password):
            APIEndpoint(
                path: "/auth/login",
                method: .POST,
                queryItems: nil,
                body: AnyEncodable(LoginRequestDTO(email: email, password: password))
            )

        case let .register(email, password):
            APIEndpoint(
                path: "/auth/register",
                method: .POST,
                queryItems: nil,
                body: AnyEncodable(RegisterRequestDTO(email: email, password: password))
            )
        }
    }
}
