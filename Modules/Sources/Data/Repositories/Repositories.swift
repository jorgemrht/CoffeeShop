import Domain
import Foundation

public struct AuthRepositoryImpl: AuthRepository, Sendable {
  
    private let api: APIService
    public init(api: APIService) { self.api = api }

    public func login(email: String, password: String) async throws -> UserSession {
        do {
            let response = try await api.post(
                AuthEndpoints.login(email: email, password: password),
                body: LoginRequestDTO(email: email, password: password)
            )
            let dto: LoginResponseDTO = try response.decoded(LoginResponseDTO.self)
            return UserSession(dto)
        } catch let appError as AppError {
            throw appError
        }
    }
}
