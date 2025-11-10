import Foundation

public protocol CoffeeRepository: Sendable {
    func getCoffees() async throws -> [CoffeeShops]
    func getCoffeeDetail(id: Int) async throws -> CoffeeDetail
}
