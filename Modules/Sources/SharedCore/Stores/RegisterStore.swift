import SwiftUI
import Tracking
import Observation
import Domain

@MainActor
@Observable
public final class RegisterStore: Injectable {

    private let authRepository: AuthRepository
    private let logRepository: LogRepositoryImpl

    public enum Navigation {
        case main
    }

    public var email: String = ""
    public var password: String = ""
    public var confirmPassword: String = ""
    public var isLoading: Bool = false
    public var errorMessage: String?
    public var navigation: Navigation?
    public private(set) var session: UserSession?

    public init(authRepository: AuthRepository, logRepository: LogRepositoryImpl) {
        self.authRepository = authRepository
        self.logRepository = logRepository
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
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres"
            return
        }

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
            navigation = .main
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

extension RegisterStore {
    public static func resolve(from container: DependencyContainer) -> RegisterStore {
        RegisterStore(authRepository: container.authRepository(), logRepository: container.logRepository())
    }
}


