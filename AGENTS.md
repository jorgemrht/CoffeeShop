# Project Guidelines
## Requirements
- Swift 6.2
- Minimum iOS SDK: 26.0
- UI Framework: SwiftUI

## Project Structure
This project has two boundaries: the app target in `CoffeeShop/CoffeeShop/` and the local Swift package in `Modules/`. The app target is organized by feature folders, but those folders are not separate Swift modules; they all compile into the same app target.

The runtime shell starts in `CoffeeShopApp.swift`, injects shared dependencies into SwiftUI environment values, and renders `AppRootView` as the root flow switch. Navigation state lives in `Core/AppState.swift`, while cross-feature shared code lives under `Core/` and `Tracking/`.

Structure:
- `CoffeeShop/CoffeeShop/AppNavigation/`
  - Root flow composition with `AppRootView`
- `CoffeeShop/CoffeeShop/Core/`
  - App-wide state, dependency injection, stores, shared types
- `CoffeeShop/CoffeeShop/FeatureSplash/`
  - Splash screen
- `CoffeeShop/CoffeeShop/FeatureLogin/`
  - Auth navigation and login screen
- `CoffeeShop/CoffeeShop/FeatureRegister/`
  - Register screen
- `CoffeeShop/CoffeeShop/FeatureMain/`
  - Tab shell and settings presentation
- `CoffeeShop/CoffeeShop/FeatureCoffee/`
  - Coffee list navigation and screen
- `CoffeeShop/CoffeeShop/FeatureCoffeeDetail/`
  - Coffee detail screen
- `CoffeeShop/CoffeeShop/FeatureShops/`
  - Shops navigation and screen
- `CoffeeShop/CoffeeShop/FeatureShopDetail/`
  - Shop detail screen
- `CoffeeShop/CoffeeShop/FeatureSettings/`
  - Settings navigation and screen
- `CoffeeShop/CoffeeShop/Tracking/`
  - Logging and device metadata
- `CoffeeShop/CoffeeShop/TestHelpers/`
  - Mocks and preview helpers for the app target
- `Modules/Sources/`
  - Local package modules: `Data`, `Domain`, `DesignSystem`, `Macros`

Inside `CoffeeShop/CoffeeShop/`, do not add pseudo-module imports like `import Core`, `import FeatureCoffee`, `import Tracking`, or `import TestHelpers`. Only import actual package modules such as `Data`, `Domain`, `DesignSystem`, and `Macros`.

## Naming Conventions
- Root app shell types use app-level names:
  - `CoffeeShopApp`
  - `AppRootView`
  - `AppState`
  - `AppRoot`
- Feature folders use `Feature<Name>` naming.
- Navigation containers use the `NavigationView` suffix:
  - `AuthNavigationView`
  - `MainNavigationView`
  - `CoffeeNavigationView`
  - `ShopsNavigationView`
  - `SettingsNavigationView`
- Rendered screens use the `ViewScreen` suffix:
  - `LoginViewScreen`
  - `CoffeeViewScreen`
  - `ShopDetailViewScreen`
- Screen state objects use the `Store` suffix:
  - `LoginStore`
  - `CoffeeStore`
  - `SettingsStore`
- Route enums use the `Route` suffix and are grouped by flow in `Core/AppState.swift`:
  - `AuthRoute`
  - `TabRoute`
  - `CoffeeRoute`
  - `ShopsRoute`
  - `SettingsRoute`
- Repositories use protocol names in `Domain` and concrete `Impl` names in `Data`:
  - `AuthRepository` / `AuthRepositoryImpl`
  - `CoffeeRepository` / `CoffeeRepositoryImpl`
- All new names, identifiers, comments, and user-facing text must be written in English.
- Keep existing `#URL(...)` usage intact unless a task explicitly asks to remove it.

## Architecture
The app uses SwiftUI Observation for UI state and Apple’s dependency system for shared infrastructure. The shared dependency root is `AppDependencies`, exposed through `EnvironmentValues` with `@Entry`, and injected once from `CoffeeShopApp`.

Dependency flow:
- `CoffeeShopApp` injects `AppDependencies.current` with `.environment(\\.appDependencies, ...)`
- `EnvironmentValues+Extension.swift` defines `@Entry var appDependencies`
- `AppDependencies` owns only the shared base dependencies:
  - `NetworkClient`
  - `LogRepositoryImpl`
- Feature repositories are created on demand through factory methods:
  - `makeAuthRepository()`
  - `makeCoffeeRepository()`
- This keeps the shared network and log layer stable without materializing every repository up front

Navigation flow:
- `AppRootView` owns `@State private var appState`
- `AppRootView` shares `appState` with `.environment(appState)`
- `AppState` is the single source of truth for root flow and navigation paths
- `NavigationView` types read `AppState` and `appDependencies`, but they do not own feature stores
- `MainViewScreen.swift` acts as the main shell for tabs and settings presentation

Feature structure:
- Each feature has a navigation container when the flow needs its own `NavigationStack`
- Each screen owns its own store with `@State`
- Each screen receives a single `environment: AppDependencies` parameter when it needs to construct its store
- Each store keeps:
  - one explicit dependency initializer for direct construction in tests/previews
  - one `init(environment: AppDependencies)` initializer that resolves repositories through `AppDependencies`
- Stores should not know how concrete repositories are built; they should call `environment.make...()` when using the environment initializer

Store ownership rules:
- Screens own stores
- Navigation views do not own stores
- Screens should not depend on `@Environment(Store.self)` for their primary store lifecycle
- The primary SwiftUI pattern in this codebase is:
  - navigation container reads environment values
  - screen creates its store with `@State`
  - screen binds to the store with `@Bindable`

Network and logging:
- `NetworkClient.default()` is the shared entry point for the app’s network layer
- `LogRepositoryImpl.default()` is the shared entry point for app logging
- `AppDependencies.live` builds from those two shared defaults
- Repositories in `Data` wrap the shared `NetworkClient`
- Stores log through `LogRepositoryImpl`

Previews and mocks:
- `AppDependencies.preview` is the preview-friendly dependency graph
- Preview and mock construction stays in `TestHelpers`
- Prefer `environment: .preview` when previewing screens that own stores

## Rules
- Only do what the user explicitly asked for.
- If you detect an important follow-up or additional change, ask for permission before doing it.
- Do not compile the project after making changes unless the user explicitly asks you to compile.
- Do not run tests after making changes unless the user explicitly asks you to run tests.
