import Foundation

public enum LoginEndpoints {
    
    case login(email: String, password: String, deviceId: String)
    case register(email: String, password: String)
    case refresh(token: String)

    public var endpoint: APIEndpoint {
        switch self {
        case let .login(email, password, deviceId):
            APIEndpoint(
                path: "/auth/login",
                method: .POST,
                queryItems: nil,
                body: LoginRequestDTO(email: email, password: password, deviceId: deviceId)
            )

        case let .register(email, password):
            APIEndpoint(
                path: "/auth/register",
                method: .POST,
                queryItems: nil,
                body: RegisterRequestDTO(email: email, password: password)
            )

        case .refresh(let token):
            APIEndpoint(
                path: "/auth/refresh",
                method: .POST,
                queryItems: nil,
                body: RefreshTokenRequestDTO(refreshToken: token)
            )
        }
    }
}
