#if DEBUG
import Foundation
import Domain

public final class MockShopRepository: ShopRepository {

    public init() { }

    public func getShops() async throws -> [UUID] {
        [UUID(), UUID(), UUID(), UUID(), UUID()]
    }
}
#endif
