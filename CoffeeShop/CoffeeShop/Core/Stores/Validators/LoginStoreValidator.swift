import Foundation

@MainActor
public protocol LoginValidating: Sendable {
    func validate(email: String, password: String) throws
}

@MainActor
public struct LoginStoreValidator: LoginValidating {
    private let emailValidator: any EmailValidating
    private let passwordValidator: any PasswordValidating

    public init(
        emailValidator: any EmailValidating,
        passwordValidator: any PasswordValidating
    ) {
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
    }

    public func validate(email: String, password: String) throws {
        try emailValidator.validate(email)
        try passwordValidator.validate(password)
    }
}
