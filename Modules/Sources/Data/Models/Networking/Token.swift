import Foundation
import Domain

public struct Token: Sendable, Codable {
    public let value: String
    public let refreshValue: String?
    public let expiry: Date?

    public init(
        value: String,
        refreshValue: String? = nil,
        expiry: Date? = nil
    ) {
        self.value = value
        self.refreshValue = refreshValue
        self.expiry = expiry
    }

    public init(session: UserSession) {
        self.init(
            value: session.token,
            refreshValue: nil,
            expiry: nil
        )
    }

    public var isValid: Bool {
        guard let expiry else {
            return true
        }

        return Date() < expiry
    }

    public var isExpired: Bool { !isValid }

    func withFallbackRefreshValue(_ fallbackRefreshValue: String) -> Token {
        Token(
            value: value,
            refreshValue: refreshValue ?? fallbackRefreshValue,
            expiry: expiry
        )
    }
}
