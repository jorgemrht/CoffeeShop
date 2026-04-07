import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class RegisterStore: StoreProtocol, StoreErrorProtocol {

    private let authRepository: AuthRepository
    private let logRepository: LogRepositoryImpl
    private let registerValidator: any RegisterValidating

    public var email: String = ""
    public var password: String = ""
    public var confirmPassword: String = ""
    public var isLoading: Bool = false
    public var errorAlert: ErrorAlertPresentation?

    public init(
        authRepository: AuthRepository,
        logRepository: LogRepositoryImpl,
        registerValidator: any RegisterValidating
    ) {
        self.authRepository = authRepository
        self.logRepository = logRepository
        self.registerValidator = registerValidator
    }

    public init(
        environment: AppDependencies
    ) {
        self.authRepository = environment.makeAuthRepository()
        self.logRepository = environment.logRepository
        self.registerValidator = RegisterStoreValidator(
            emailValidator: EmailValidator(),
            passwordValidator: PasswordValidator(minimumLength: 6),
            passwordConfirmationValidator: PasswordConfirmationValidator()
        )
    }

    public func register() async -> Bool {
        do {
            try registerValidator.validate(
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )

            let didRegister = try await withLoading {
                _ = try await authRepository.register(email: email, password: password)
                return true
            }

            return didRegister ?? false
        } catch {
            errorAlert = ErrorAlertPresentation(
                title: "Registration Failed",
                message: "We could not create your account at this time.",
                dismissButtonTitle: "OK"
            )
            await logRepository.log(.error, .authentication, error: error)
            return false
        }
    }
}
