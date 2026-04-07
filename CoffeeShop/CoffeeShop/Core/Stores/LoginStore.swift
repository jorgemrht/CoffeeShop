import Foundation
import Observation
import Domain

@MainActor
@Observable
public final class LoginStore: StoreProtocol, StoreErrorProtocol {

    private let authRepository: AuthRepository
    private let logRepository: LogRepositoryImpl
    private let loginValidator: LoginValidating

    public var email: String = ""
    public var password: String = ""
    public var isLoading: Bool = false
    public var errorAlert: ErrorAlertPresentation?

    public init(
        authRepository: AuthRepository,
        logRepository: LogRepositoryImpl,
        loginValidator: any LoginValidating
    ) {
        self.authRepository = authRepository
        self.logRepository = logRepository
        self.loginValidator = loginValidator
    }

    public init(
        environment: AppDependencies
    ) {
        self.authRepository = environment.makeAuthRepository()
        self.logRepository = environment.logRepository
        self.loginValidator = LoginStoreValidator(
            emailValidator: EmailValidator(),
            passwordValidator: PasswordValidator()
        )
    }

    public func login() async -> Bool {
        do {
            try loginValidator.validate(email: email, password: password)

            let didLogin = try await withLoading {
                _ = try await authRepository.login(email: email, password: password)
                return true
            }

            return didLogin ?? false
        } catch {
            errorAlert = ErrorAlertPresentation(
                title: "Login Failed",
                message: "We could not sign you in with the provided credentials.",
                dismissButtonTitle: "OK"
            )
            await logRepository.log(.error, .authentication, error: error)
            return false
        }
    }
}
