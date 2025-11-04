import Foundation
import SwiftUI
import Observation
import Domain

// DOC: https://developer.apple.com/documentation/SwiftUI/NavigationStack
// DOC: https://developer.apple.com/documentation/swiftui/navigationpath
// DOC: https://developer.apple.com/documentation/observation/observable()
// DOC: https://developer.apple.com/documentation/Swift/MainActor
// DOC: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency

public enum RootView: Sendable {
    case splash
    case auth
    case home
}

// Auth
public enum AuthRoute: Sendable {
    case register
}

// Tabbar tab
public enum TabRoute: Sendable {
    case shops
    case settings
}

// Shops tab
public enum ShopsRoute: Sendable {
    case main
    case detail(id: Int)
}

// Settings tab
public enum SettingsRoute: Sendable {
    case main
}

@Observable
public final class AppState {
    
    // Tab bar
    public var selectedTab: TabRoute = .shops

    // Paths
    public var authPath: [AuthRoute] = []
    public var shopsPath: [ShopsRoute] = [.main]
    public var settingsPath: [SettingsRoute] = [.main]
    
    public private(set) var root: RootView

    public init(root: RootView) {
        self.root = root
    }
    
    public func transition(to root: RootView) {
        self.root = root
    }

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
        shopsPath = [.main]
        settingsPath = [.main]
    }
}

public extension EnvironmentValues {
    @Entry var appState: AppState?
}
