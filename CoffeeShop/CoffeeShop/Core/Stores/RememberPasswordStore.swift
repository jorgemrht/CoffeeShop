import Foundation
import Observation

@MainActor
@Observable
public final class RememberPasswordStore: StoreProtocol, StoreErrorProtocol {

    private let logRepository: LogRepositoryImpl
    private let emailValidator: any EmailValidating

    public var email: String = ""
    public var isLoading: Bool = false
    public var recoveryRequested: Bool = false
    public var errorAlert: ErrorAlertPresentation?

    public init(
        logRepository: LogRepositoryImpl,
        emailValidator: any EmailValidating
    ) {
        self.logRepository = logRepository
        self.emailValidator = emailValidator
    }

    public init(environment: AppDependencies) {
        self.logRepository = environment.logRepository
        self.emailValidator = EmailValidator()
    }

    public func requestRecovery() async -> Bool {
        do {
            try emailValidator.validate(email)
            recoveryRequested = true
            return true
        } catch {
            errorAlert = ErrorAlertPresentation(
                title: "Recovery Failed",
                message: "We could not prepare the recovery instructions for this email.",
                dismissButtonTitle: "OK"
            )
            await logRepository.log(.error, .authentication, error: error)
            return false
        }
    }
}
