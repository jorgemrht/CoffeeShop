import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class LoginStore: Injectable {

    public enum Navigation {
        case main
    }

    private let authRepository: AuthRepository

    public var email: String = ""
    public var password: String = ""
    public var isLoading: Bool = false
    public private(set) var session: UserSession?
    public var navigation: Navigation?

    // MARK: - Initialization

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public var isLoginEnabled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !isLoading
    }

    public func login() async {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let userSession = try await authRepository.login(email: email, password: password)
            session = userSession
        } catch {  }
    }
}

extension LoginStore {
    public static func resolve(from container: DependencyContainer) -> LoginStore {
        LoginStore(authRepository: container.authRepository())
    }
}
