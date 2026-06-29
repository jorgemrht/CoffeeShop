import Domain
import Foundation
import OSLog

public struct AuthRepositoryImpl: AuthRepository, Sendable {

    private let networkClient: NetworkClient
    private let deviceIdentityDataSource: any DeviceIdentityDataSource

    public init(networkClient: NetworkClient) {
        self.init(
            networkClient: networkClient,
            deviceIdentityDataSource: .default()
        )
    }

    init(
        networkClient: NetworkClient,
        deviceIdentityDataSource: any DeviceIdentityDataSource
    ) {
        self.networkClient = networkClient
        self.deviceIdentityDataSource = deviceIdentityDataSource
    }

    public func login(email: String, password: String) async throws -> UserSession {
        do {
            let response = try await networkClient.request(
                LoginEndpoints.login(
                    email: email,
                    password: password,
                    deviceId: try deviceIdentityDataSource.deviceId()
                ).endpoint
            )

            let session = try response.decoded(LoginResponseDTO.self).toDomain()
            try await networkClient.saveSession(session)
            return session
        } catch let apiError as APIError {
            throw apiError.toDomain()
        } catch {
            throw AppError.internalError(error)
        }
    }

    public func register(email: String, password: String) async throws -> UserSession {
        do {
            let response = try await networkClient.request(
                LoginEndpoints.register(email: email, password: password).endpoint
            )

            let session = try response.decoded(LoginResponseDTO.self).toDomain()
            try await networkClient.saveSession(session)
            return session
        } catch let apiError as APIError {
            throw apiError.toDomain()
        } catch {
            throw AppError.internalError(error)
        }
    }
}

private extension DeviceIdentityDataSource where Self == DeviceIdentityDataSourceImpl {
    static func `default`() -> DeviceIdentityDataSourceImpl {
        let configuration = NetworkClientConfiguration.live(bundleIdentifier: Bundle.main.bundleIdentifier)
        return DeviceIdentityDataSourceImpl(
            keychainDataSource: KeychainDataSourceImpl(),
            service: configuration.keychainService
        )
    }
}
