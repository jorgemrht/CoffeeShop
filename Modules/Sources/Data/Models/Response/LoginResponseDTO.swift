import Domain
import Foundation

public struct LoginResponseDTO: Decodable {
    public let token: String
    public let refreshToken: String?
    public let expiresIn: TimeInterval?
    public let expiresAt: Date?

    public init(
        token: String,
        refreshToken: String? = nil,
        expiresIn: TimeInterval? = nil,
        expiresAt: Date? = nil
    ) {
        self.token = token
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.expiresAt = expiresAt
    }
}

extension LoginResponseDTO {
    func toDomain() -> UserSession {
        .init(
            token: token,
            refreshToken: refreshToken,
            expiry: expiresAt ?? expiresIn.map { Date().addingTimeInterval($0) }
        )
    }
}
