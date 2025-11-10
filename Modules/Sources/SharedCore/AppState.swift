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

@Observable
public final class AppState {

    // Tab bar
    public var selectedTab: TabRoute = .coffee

    // Paths
    public var authPath: [AuthRoute] = []
    public var coffeePath: [CoffeeRoute] = []
    public var shopsPath: [ShopsRoute] = []
    public var settingsPath: [SettingsRoute] = []
    
    public private(set) var root: RootView

    public init(root: RootView) {
        self.root = root
    }
    
    public func transition(to root: RootView) {
        self.root = root
    }

    @MainActor public func openCoffeeDetail(id: Int) {
        selectedTab = .coffee
        coffeePath = [.detail(id: id)]
    }

    @MainActor public func resetForLogout() {
        selectedTab = .coffee
        coffeePath = []
        shopsPath = []
        settingsPath = []
    }
}

