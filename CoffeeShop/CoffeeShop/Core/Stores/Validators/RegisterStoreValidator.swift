import Foundation

@MainActor
public protocol RegisterValidating: Sendable {
    func validate(email: String, password: String, confirmPassword: String) throws
}

@MainActor
public struct RegisterStoreValidator: RegisterValidating {
    private let emailValidator: any EmailValidating
    private let passwordValidator: any PasswordValidating
    private let passwordConfirmationValidator: any PasswordConfirmationValidating

    public init(
        emailValidator: any EmailValidating,
        passwordValidator: any PasswordValidating,
        passwordConfirmationValidator: any PasswordConfirmationValidating
    ) {
        self.emailValidator = emailValidator
        self.passwordValidator = passwordValidator
        self.passwordConfirmationValidator = passwordConfirmationValidator
    }

    public func validate(email: String, password: String, confirmPassword: String) throws {
        try emailValidator.validate(email)
        try passwordValidator.validate(password)
        try passwordConfirmationValidator.validate(password: password, confirmation: confirmPassword)
    }
}
