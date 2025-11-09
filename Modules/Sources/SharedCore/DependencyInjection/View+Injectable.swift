import SwiftUI

extension View {
    public func withStore<Store: Injectable & Observable>(_ storeType: Store.Type) -> some View {
        modifier(StoreInjector<Store>())
    }
}

// MARK: - Private ViewModifier

private struct StoreInjector<Store: Injectable & Observable>: ViewModifier {
    @Environment(\.self) private var environment

    func body(content: Content) -> some View {
        let container = DependencyContainer(environment: environment)
        let store = Store.resolve(from: container)

        content.environment(store)
    }
}
