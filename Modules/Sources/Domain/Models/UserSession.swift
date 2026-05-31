import Foundation

public struct UserSession: Sendable {
    public let token: String
    public let refreshToken: String?
    public let expiry: Date?
    
    public init(
        token: String,
        refreshToken: String? = nil,
        expiry: Date? = nil
    ) {
        self.token = token
        self.refreshToken = refreshToken
        self.expiry = expiry
    }
}
