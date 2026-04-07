import Foundation

@MainActor
public protocol EmailValidating: Sendable {
    func validate(_ email: String) throws
}

public enum EmailValidationError: LocalizedError {
    case emailRequired

    public var errorDescription: String? {
        switch self {
        case .emailRequired:
            "Email is required."
        }
    }
}

@MainActor
public struct EmailValidator: EmailValidating {
    public init() { }

    public func validate(_ email: String) throws {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw EmailValidationError.emailRequired
        }
    }
}
