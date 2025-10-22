import Foundation

public struct Token: Sendable, Equatable, Codable {
    public let value: String
    public let expiry: Date
    
    public init(value: String, expiry: Date) {
        self.value = value
        self.expiry = expiry
    }
    
    public var isValid: Bool { Date() < expiry }
}

public final class AuthManager {
    
    // func saveToken
    
    // refreshToken
}
