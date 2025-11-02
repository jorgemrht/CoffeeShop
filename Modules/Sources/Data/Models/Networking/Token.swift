import Foundation

public struct Token: Sendable, Codable {
    public let value: String
    public let expiry: Date

    public init(value: String, expiry: Date) {
        self.value = value
        self.expiry = expiry
    }

    public var isValid: Bool { Date() < expiry }
    public var isExpired: Bool { !isValid }
}
