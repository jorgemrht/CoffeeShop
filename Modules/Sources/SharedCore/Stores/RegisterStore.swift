import SwiftUI
import Observation
import Domain

@MainActor
@Observable
public final class RegisterStore {

    private let authRepository: AuthRepository

    public enum NavigationEvent {
        case home
    }

    public var email: String = ""
    public var password: String = ""
    public var confirmPassword: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?
    public private(set) var session: UserSession?

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public var isRegisterEnabled: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        !isLoading
    }

    public func register() async {
        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden"
            return
        }

        // Validate password strength
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres"
            return
        }

        // Validate email
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "El email es requerido"
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let userSession = try await authRepository.register(email: email, password: password)
            session = userSession
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
