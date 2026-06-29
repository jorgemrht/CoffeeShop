import Foundation

public protocol CoffeeRepository: Sendable {
    func getCoffees() async throws -> [CoffeeShops]
    func getCoffeeDetail(id: UUID) async throws -> CoffeeDetail
}
