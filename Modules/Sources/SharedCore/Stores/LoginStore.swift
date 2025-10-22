import Domain
import Foundation
import Observation

@Observable
public final class LoginStore {

    private let authRepository: AuthRepository

    public var email: String = ""
    public var password: String = ""

    public var isLoading: Bool = false
    public var errorMessage: String? = nil

    public private(set) var session: UserSession? = nil

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    @MainActor
    public func login() async {
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !password.isEmpty else {
            errorMessage = "Introduce email y contraseña."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await authRepository.login(email: email, password: password)
            self.session = session
        } catch {
            errorMessage = "No se pudo iniciar sesión. Inténtalo de nuevo."
        }
    }

    @MainActor
    public func clearError() {
        errorMessage = nil
    }
}
