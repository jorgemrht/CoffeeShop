import Foundation
import Domain

public final class MockShopRepository: ShopRepository {

    public init() { }

    public func getShops() async throws -> [Int] {
        [1, 2, 3, 4, 5]
    }
}
