import Foundation
import Observation

// DOC: https://developer.apple.com/documentation/SwiftUI/NavigationStack
// DOC: https://developer.apple.com/documentation/swiftui/navigationpath
// DOC: https://developer.apple.com/documentation/observation/observable()
// DOC: https://developer.apple.com/documentation/Swift/MainActor
// DOC: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency

public enum TabID: Hashable { case shops, settings }

// Auth
public enum AuthRoute: Hashable { case login, register }

// Shops tab
public enum ShopsRoute: Hashable {
    case main
    case detail(id: Int)
}

// Settings tab
public enum SettingsRoute: Hashable { case main }

@Observable
public final class AppState {
    // Sesión
    public var isLoggedIn: Bool = false

    // Tab bar
    public var selectedTab: TabID = .shops

    // Paths
    public var authPath: [AuthRoute] = [.login]
    public var shopsPath: [ShopsRoute] = [.main]
    public var settingsPath: [SettingsRoute] = [.main]

    public init() {}

    // Helpers
    @MainActor public func openShopDetail(id: Int) {
        selectedTab = .shops
        shopsPath = [.main, .detail(id: id)]
    }
    @MainActor public func goHome() {
        selectedTab = .shops
        shopsPath = [.main]
    }
    @MainActor public func resetForLogout() {
        selectedTab = .shops
        authPath = [.login]
        shopsPath = [.main]
        settingsPath = [.main]
        isLoggedIn = false
    }
}
