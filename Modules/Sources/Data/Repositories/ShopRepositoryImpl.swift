import Domain
import Foundation

public struct ShopRepositoryImpl: ShopRepository, Sendable {

    private let networkClient: NetworkClient

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func getShops() async throws -> [UUID] {
        do {
            let response = try await networkClient.request(
                ShopEndpoints.shops.endpoint
            )

            return try response.decoded([UUID].self)
        } catch let apiError as APIError {
            throw apiError.toDomain()
        } catch {
            throw AppError.internalError(error)
        }
    }
}
