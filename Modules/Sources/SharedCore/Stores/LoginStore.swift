import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class LoginStore {

    public enum Navigation {
        case main
    }
    
    public let authRepository: AuthRepository

    public var email: String = ""
    public var password: String = ""
    public var isLoading: Bool = false
    public private(set) var session: UserSession?
    public var navigation: Navigation?
    
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
