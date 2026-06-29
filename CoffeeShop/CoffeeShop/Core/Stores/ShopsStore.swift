import SwiftUI
import Observation
import Domain
import Foundation

@MainActor
@Observable
public final class ShopsStore: StoreProtocol, StoreErrorProtocol {

    private let shopRepository: ShopRepository
    private let logRepository: LogRepositoryImpl
    public var isLoading: Bool = false
    public var shops: [UUID] = []
    public var errorAlert: ErrorAlertPresentation?

    public init(
        shopRepository: ShopRepository,
        logRepository: LogRepositoryImpl
    ) {
        self.shopRepository = shopRepository
        self.logRepository = logRepository
    }

    public init(environment: AppDependencies) {
        self.shopRepository = environment.makeShopRepository()
        self.logRepository = environment.logRepository
    }

    public func loadShops() async {
        do {
            try await withLoading {
                shops = try await shopRepository.getShops()
            }
        } catch {
            errorAlert = ErrorAlertPresentation(
                title: "Unable to Load Shops",
                message: "We could not load the shop list right now.",
                dismissButtonTitle: "OK"
            )
            await logRepository.log(.error, .network, error: error)
        }
    }
}
