import Domain
import Foundation

public struct CoffeeRepositoryImpl: CoffeeRepository, Sendable {

    private let networkClient: NetworkClient

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func getCoffees() async throws -> [CoffeeShops] {
        do {
            let response = try await networkClient.request(
                CoffeeEndpoints.list.endpoint
            )

            return try response.decoded([CoffeeShopsResponseDTO].self).toDomain()
        } catch let apiError as APIError {
            throw apiError.toDomain()
        } catch {
            throw AppError.internalError(error)
        }
    }

    public func getCoffeeDetail(id: Int) async throws -> CoffeeDetail {
        do {
            let response = try await networkClient.request(
                CoffeeEndpoints.detail(id: id).endpoint
            )

            return try response.decoded(CoffeeDetailResponseDTO.self).toDomain()
        } catch let apiError as APIError {
            throw apiError.toDomain()
        } catch {
            throw AppError.internalError(error)
        }
    }
}
