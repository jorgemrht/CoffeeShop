import Foundation
import SwiftUI
import Observation
import Domain

public enum AppRoot: Sendable {
    case splash
    case auth
    case main
}

// Auth
public enum AuthRoute: Sendable {
    case register
}

// TabBar tabs
public enum TabRoute: Sendable {
    case coffee
    case shops
}

// Coffee tab routes
public enum CoffeeRoute: Sendable, Hashable {
    case detail(id: Int)
}

// Shops tab routes
public enum ShopsRoute: Sendable, Hashable {
    case detail(id: Int)
}

// Settings
public enum SettingsRoute: Sendable, Hashable {
    case settings
}

@MainActor
@Observable
public final class AppState {

    // Tab bar
    public var selectedTab: TabRoute = .coffee

    // Paths
    public var authPath: [AuthRoute] = []
    public var coffeePath: [CoffeeRoute] = []
    public var shopsPath: [ShopsRoute] = []
    public var settingsPath: [SettingsRoute] = []
    
    public private(set) var root: AppRoot

    public init(root: AppRoot) {
        self.root = root
    }
    
    public func transition(to root: AppRoot) {
        self.root = root
    }

    public func openCoffeeDetail(id: Int) {
        selectedTab = .coffee
        coffeePath = [.detail(id: id)]
    }

    public func resetForLogout() {
        selectedTab = .coffee
        coffeePath = []
        shopsPath = []
        settingsPath = []
    }
}
