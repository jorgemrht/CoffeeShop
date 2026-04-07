import Foundation

public protocol ShopRepository: Sendable {
    func getShops() async throws -> [Int]
}
