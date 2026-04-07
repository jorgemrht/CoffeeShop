import Foundation

@MainActor
public protocol PasswordConfirmationValidating: Sendable {
    func validate(password: String, confirmation: String) throws
}

public enum PasswordConfirmationValidationError: LocalizedError {
    case passwordsDoNotMatch

    public var errorDescription: String? {
        switch self {
        case .passwordsDoNotMatch:
            "Passwords do not match."
        }
    }
}

@MainActor
public struct PasswordConfirmationValidator: PasswordConfirmationValidating {
    public init() { }

    public func validate(password: String, confirmation: String) throws {
        guard password == confirmation else {
            throw PasswordConfirmationValidationError.passwordsDoNotMatch
        }
    }
}
