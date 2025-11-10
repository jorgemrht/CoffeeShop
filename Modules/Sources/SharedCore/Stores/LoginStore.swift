import SwiftUI
import Observation
import Domain
import Tracking

@MainActor
@Observable
public final class LoginStore: Injectable {

    public enum Navigation {
        case main
    }

    private let authRepository: AuthRepository
    private let logRepository: LogRepositoryImpl

    public var email: String = ""
    public var password: String = ""
    public var isLoading: Bool = false
    public var navigation: Navigation?

    public init(authRepository: AuthRepository,
                logRepository: LogRepositoryImpl
    ) {
        self.authRepository = authRepository
        self.logRepository = logRepository
    }

    public var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !isLoading
    }

    public func login() async {
        
        navigation = .main
//        
//        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
//              !password.isEmpty else {
//            return
//        }
//
//        isLoading = true
//        defer { isLoading = false }
//
//        do {
//            let userSession = try await authRepository.login(email: email, password: password)
//            session = userSession
//            navigation = .main
//        } catch {
//            await logRepository.log(.error, .authentication, error: error)
//        }
    }
}

extension LoginStore {
    public static func resolve(from container: DependencyContainer) -> LoginStore {
        LoginStore(
            authRepository: container.authRepository(),
            logRepository: container.logRepository()
        )
    }
}
