import Foundation

@MainActor
public protocol PasswordValidating: Sendable {
    func validate(_ password: String) throws
}

public enum PasswordValidationError: LocalizedError {
    case passwordRequired
    case passwordTooShort(minimumLength: Int)

    public var errorDescription: String? {
        switch self {
        case .passwordRequired:
            "Password is required."
        case .passwordTooShort(let minimumLength):
            "Password must be at least \(minimumLength) characters."
        }
    }
}

@MainActor
public struct PasswordValidator: PasswordValidating {
    private let minimumLength: Int

    public init(minimumLength: Int = 1) {
        self.minimumLength = minimumLength
    }

    public func validate(_ password: String) throws {
        guard !password.isEmpty else {
            throw PasswordValidationError.passwordRequired
        }

        guard password.count >= minimumLength else {
            throw PasswordValidationError.passwordTooShort(minimumLength: minimumLength)
        }
    }
}
