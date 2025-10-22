import Domain
import Foundation

public struct AuthRepositoryImpl: AuthRepository, Sendable {

    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func login(email: String, password: String) async throws -> UserSession {
        do {
            let response = try await networkClient.request(
                LoginEndpoints.login(email: email, password: password).endpoint
            )
            
            return try response.decoded(LoginResponseDTO.self).toDomain()
        } catch let apiError as APIError {
            throw apiError.toDomain()
        } catch {
            throw AppError.internalError(error)
        }
    }
}
