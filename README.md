# CoffeeShop

CoffeeShop is a SwiftUI reference app and starter architecture for building modern iOS apps with clear ownership boundaries.

The project is intentionally small in product scope and opinionated in structure so developers can quickly understand how dependencies, navigation, stores, and reusable modules fit together.

## Table of Contents

- [Requirements](#requirements)
- [Overview](#overview)
- [Architecture](#architecture)
- [Project Organization](#project-organization)
- [Dependency Injection](#dependency-injection)
- [Responsibilities and Scope](#responsibilities-and-scope)
- [Navigation](#navigation)
- [Flow Pattern](#flow-pattern)
- [Stores](#stores)
- [Validation](#validation)
- [Modules](#modules)
- [Naming Conventions](#naming-conventions)
- [Repository Rules](#repository-rules)

## Requirements

- Xcode 26
- Swift 6.2
- Minimum iOS SDK: 26.0
- UI Framework: SwiftUI

## Overview

CoffeeShop is designed as a practical base for teams who want an example of a modern SwiftUI app without hiding ownership behind overly abstract layers.

The sample covers:

- Root flow switching with `splash`, `auth`, and `main`
- Flow-local navigation with dedicated routers
- Explicit stores built with SwiftUI Observation
- Shared dependency injection through the SwiftUI environment
- A local Swift package that separates infrastructure, contracts, UI primitives, and compile-time helpers

## Architecture

The project is split into two boundaries:

- `CoffeeShop/CoffeeShop/`: the app target. It owns the app shell, flow coordination, feature screens, stores, tracking, and preview helpers.
- `Modules/`: the local Swift package. It owns reusable modules such as `Data`, `Domain`, `DesignSystem`, and `Macros`.

This separation keeps app-specific ownership in the app target while moving reusable contracts and infrastructure behind explicit package boundaries.

Within the app target, feature folders organize code, but they are not separate Swift modules. Inside `CoffeeShop/CoffeeShop/`, only real package modules such as `Data`, `Domain`, `DesignSystem`, and `Macros` should be imported.

## Project Organization

```text
CoffeeShop/
├── CoffeeShop/
│   ├── AppNavigation/
│   │   └── Navigation/
│   │       ├── Auth/
│   │       ├── Coffee/
│   │       ├── Main/
│   │       ├── Settings/
│   │       └── Shops/
│   ├── Core/
│   │   ├── DependencyInjection/
│   │   ├── Stores/
│   │   ├── Validation/
│   │   └── ViewModifiers/
│   ├── Feature/
│   │   ├── FeatureCoffee/
│   │   ├── FeatureCoffeeDetail/
│   │   ├── FeatureLogin/
│   │   ├── FeatureMain/
│   │   ├── FeatureRegister/
│   │   ├── FeatureRememberPassword/
│   │   ├── FeatureSettings/
│   │   ├── FeatureShopDetail/
│   │   ├── FeatureShops/
│   │   └── FeatureSplash/
│   ├── TestHelpers/
│   └── Tracking/
└── Modules/
    ├── Package.swift
    └── Sources/
        ├── Data/
        ├── DesignSystem/
        ├── Domain/
        ├── Macros/
        └── TestHelpers/
```

Main responsibilities:

| Path | Responsibility |
| --- | --- |
| `AppNavigation/` | Root app flow plus flow-local navigation containers and routers |
| `Core/` | Dependency injection, base store contracts, validators, shared app modifiers, and app-wide utilities |
| `Feature/` | Rendered screens and feature UI |
| `Tracking/` | Logging and device metadata |
| `TestHelpers/` | Mocks and preview helpers |

## Dependency Injection

Dependency injection starts at the app shell:

- `CoffeeShopApp` injects one `AppDependencies` value into the SwiftUI environment.
- `AppDependencies` owns the shared infrastructure root, including `NetworkClient` and `LogRepositoryImpl`.
- Feature repositories are created on demand through factories such as `makeAuthRepository()`, `makeCoffeeRepository()`, and `makeShopRepository()`.
- Screens receive `environment: AppDependencies`, and stores resolve repositories through that environment initializer.

This keeps the shared infrastructure stable while avoiding a large global dependency registry.

CoffeeShop uses different forms of injection depending on the scope of the dependency:

| Mechanism | Used for | Example |
| --- | --- | --- |
| SwiftUI `Environment` | Shared runtime context needed by many descendants | `AppDependencies`, flow routers |
| Initializer injection | Concrete collaborators a type needs to do its job | repositories, validators, loggers, network client |
| Factory methods in `AppDependencies` | Creating feature repositories from shared infrastructure | `makeAuthRepository()` |

Typical dependency flow:

`ViewScreen -> Store -> Validator / Repository -> NetworkClient -> API`

## Responsibilities and Scope

Each type has one job and one clear scope.

| Type | Responsibility | Does not own |
| --- | --- | --- |
| `CoffeeShopApp` | App bootstrap and dependency injection | Feature state, feature navigation |
| `AppRootView` | Root flow switching | Feature-local routes |
| `NavigationView` types | Flow coordination and destination resolution | Feature business logic |
| `Router` types | Navigation state only | Validation, networking, business rules |
| `ViewScreen` types | UI rendering and intent forwarding | Validation, repositories, route ownership |
| `Store` types | Feature state and feature logic | Root navigation ownership, transport details |
| Validators | Input rules | Networking, persistence, UI |
| Repository protocols | Capability contracts | Transport implementation details |
| Repository implementations | Data access and mapping | UI state, navigation |
| `NetworkClient` | Request execution and interceptor chain | Feature rules |

If a type needs behavior outside its scope, that behavior is provided as a dependency instead of being absorbed into the type.

Example:

- `LoginStore` owns login state and login orchestration
- `LoginStoreValidator` owns login input validation
- `AuthRepository` owns the authentication contract
- `AuthRepositoryImpl` owns the transport and DTO mapping
- `LogRepositoryImpl` owns logging side effects

## Navigation

Navigation is intentionally split by ownership:

- `AppRootView` owns the root flow state.
- `AppNavigation` stores only app-global navigation state.
- Each flow owns its own router inside `AppNavigation/Navigation/`.
- Navigation containers translate user intent into route changes.
- Stores do not mutate routes directly.

There is one parent navigation container per flow. That container is the runtime owner of the flow router.

Router ownership:

| Owner | Responsibility |
| --- | --- |
| `AppNavigation` | Root flow: `splash`, `auth`, `main` |
| `AuthRouter` | Auth sheets such as sign up and password recovery |
| `MainRouter` | Main tab selection and settings sheet presentation |
| `CoffeeRouter` | Coffee stack navigation |
| `ShopsRouter` | Shops stack navigation |
| `SettingsRouter` | Local settings navigation |

Router patterns:

| Pattern | State owner | Stored state | Used for |
| --- | --- | --- | --- |
| Root flow | `AppRootView` / `AppNavigation` | `root` | Switching between `splash`, `auth`, and `main` |
| Stack flow | `NavigationRouter` | `path: [Route]` | Push-based navigation inside a flow |
| Sheet flow | `SheetNavigationRouter` | `presentedSheet: Sheet?` | Modal presentation owned by a flow |
| Shell flow | `MainRouter` | `selectedTab` + `presentedSheet` | Tabs plus sheet presentation in the main shell |

Current flow map:

- Root flow: `Splash -> Auth -> Main`
- Auth flow: `Login` can present `Register` and `Remember Password` as sheets
- Main flow: `MainRouter` owns the selected tab and presents `Settings`
- Coffee flow: `Coffee -> Coffee Detail`
- Shops flow: `Shops -> Shop Detail -> Coffee Detail`

Why this split:

- Root transitions stay centralized
- Feature navigation stays local to the flow that owns it
- Screen state and navigation state do not leak into each other

## Flow Pattern

Every flow follows the same high-level recipe:

1. A parent `NavigationView` owns the router with `@State`.
2. The router is exposed to descendants through `Environment`.
3. Store ownership is created explicitly by the view or parent owner that needs that state.
4. Screens trigger local navigation through the router.
5. Cross-flow transitions go upward through closures and are resolved by the parent owner.

Path-based flow example:

```swift
public struct CoffeeNavigationView: View {
    @Environment(\.appDependencies) private var dependencies
    @State private var coffeeRouter = CoffeeRouter()

    public var body: some View {
        @Bindable var coffeeRouter = coffeeRouter

        MainTabNavigationContainer(path: $coffeeRouter.path) {
            CoffeeViewScreen(environment: dependencies)
                .navigationDestination(for: CoffeeRouter.Route.self) { route in
                    switch route {
                    case .detail(let id):
                        CoffeeDetailViewScreen(coffeeId: id, environment: dependencies)
                    }
                }
        }
        .environment(coffeeRouter)
    }
}
```

In this pattern:

- `CoffeeNavigationView` is the parent owner of the coffee flow
- `CoffeeRouter` stores the stack path
- `CoffeeViewScreen` pushes `CoffeeRouter.Route.detail`
- `CoffeeDetailViewScreen` is resolved by the container, not by the store
- `MainTabNavigationContainer` centralizes the shared `NavigationStack` and settings toolbar used by tab flows

Sheet-based flow example:

```swift
public struct AuthNavigationView: View {
    @Environment(\.appDependencies) private var dependencies
    @State private var authRouter = AuthRouter()

    public var body: some View {
        @Bindable var authRouter = authRouter

        LoginViewScreen(environment: dependencies)
            .sheet(item: $authRouter.presentedSheet) { sheet in
                switch sheet {
                case .signUp:
                    RegisterViewScreen(environment: dependencies)
                case .forgotPassword:
                    RememberPasswordViewScreen(environment: dependencies)
                }
            }
            .environment(authRouter)
    }
}
```

In this pattern:

- `AuthRouter` owns modal state only
- `LoginViewScreen` can present local auth sheets
- The parent container decides which sheet view is rendered
- successful authentication leaves the auth flow through a parent callback, not by mutating root state from the store

Cross-flow example:

```swift
switch appNavigation.root {
case .splash:
    SplashViewScreen { destination in
        switch destination {
        case .auth:
            setRoot(.auth)
        case .main:
            setRoot(.main)
        }
    }
case .auth:
    AuthNavigationView {
        setRoot(.main)
    }
case .main:
    MainNavigationView {
        setRoot(.auth)
    }
}
```

This keeps app-wide transitions separate from feature-local routing:

- local routes stay in routers
- root transitions stay in `AppRootView`
- stores remain reusable because they do not own navigation

## Stores

Stores are explicit state models built with SwiftUI Observation:

- Stores are `@Observable` and `@MainActor`
- All stores conform to `StoreProtocol` and `StoreErrorProtocol`
- Stores own feature state, validation, loading, error presentation, and repository calls
- A store can be used by one or more views, depending on where the state owner lives
- Views render UI, bind state, and forward user intent

Shared store contracts:

- `StoreProtocol` standardizes `isLoading` and `init(environment:)`
- `StoreErrorProtocol` standardizes `errorAlert`

Construction pattern:

- Stores expose an explicit dependency initializer for tests and previews
- Stores also expose `init(environment: AppDependencies)` for app wiring
- The owner of the state decides where the store instance is created
- In the current sample, many feature entry views create stores locally with `@State`
- The convenience environment initializer assembles the default collaborators for that store

This keeps store lifetime explicit, keeps views lightweight, and makes testing easier without coupling feature logic to global state.

Shared screen behavior is standardized through common modifiers:

- `backgroundView()`
- `loadingView(...)`
- `errorAlertView(..., onDismiss:)`

Screen pattern example:

```swift
public struct LoginViewScreen: View {
    @Environment(AuthRouter.self) private var authRouter
    @State private var loginStore: LoginStore

    public init(environment: AppDependencies) {
        _loginStore = State(initialValue: LoginStore(environment: environment))
    }
}
```

This is a common CoffeeShop screen pattern:

- a view can create the store explicitly with `@State`
- the screen reads the flow router from `Environment` when needed
- the store owns feature logic
- the view forwards user intent but does not absorb business rules

Reusable store example:

- `CoffeeStore` is used by both `CoffeeViewScreen` and `CoffeeDetailViewScreen`
- the type is reusable across views even when each view currently creates its own instance
- the architectural point is that the store models feature state and behavior, not that it belongs permanently to a single view type

## Validation

Validation is intentionally separated from views and from the data layer.

Validation layers in the project:

| Layer | Responsibility | Examples |
| --- | --- | --- |
| Primitive validators | Validate one rule | `EmailValidator`, `PasswordValidator`, `PasswordConfirmationValidator` |
| Feature validators | Compose the rules needed by a feature | `LoginStoreValidator`, `RegisterStoreValidator` |
| Stores | Decide when validation runs before side effects | `LoginStore`, `RegisterStore`, `RememberPasswordStore` |

This keeps validation reusable and prevents stores from absorbing every rule themselves.

Login flow example:

```swift
public final class LoginStore: StoreProtocol, StoreErrorProtocol {
    private let authRepository: AuthRepository
    private let logRepository: LogRepositoryImpl
    private let loginValidator: LoginValidating

    public func login() async -> Bool {
        do {
            try loginValidator.validate(email: email, password: password)
            let didLogin = try await withLoading {
                _ = try await authRepository.login(email: email, password: password)
                return true
            }
            return didLogin ?? false
        } catch {
            errorAlert = ErrorAlertPresentation(
                title: "Login Failed",
                message: "We could not sign you in with the provided credentials.",
                dismissButtonTitle: "OK"
            )
            await logRepository.log(.error, .authentication, error: error)
            return false
        }
    }
}
```

What this example shows:

- the store decides when validation happens
- the validator performs the validation work
- the repository performs the auth request
- the log repository handles logging
- the store coordinates the flow, but it does not absorb all responsibilities itself

This same principle applies to networking and infrastructure:

- stores depend on repository protocols instead of transport code
- repository implementations depend on `NetworkClient`
- `NetworkClient` owns request execution and interceptor composition
- each layer stays focused on its own scope

## Modules

The local Swift package keeps reusable concerns outside the app target:

- `Domain`: models, app errors, and repository protocols. This is the stable contract boundary.
- `Data`: endpoints, DTOs, networking, interceptors, and repository implementations. This keeps infrastructure details out of UI code.
- `DesignSystem`: shared symbols, toolbar helpers, assets, and view modifiers. This centralizes reusable UI behavior and accessibility-aware primitives.
- `Macros`: compile-time helpers such as `#URL(...)`. This adds safety without runtime overhead.

This split improves clarity, reuse, and testability while keeping the app shell free to own runtime coordination.

## Naming Conventions

CoffeeShop follows explicit role-based naming:

- App shell types use app-level names such as `CoffeeShopApp`, `AppRootView`, and `AppNavigation`
- Navigation containers use the `NavigationView` suffix
- Flow owners use the `Router` suffix
- Rendered screens use the `ViewScreen` suffix
- Screen state objects use the `Store` suffix
- Navigation destinations use the `Route` suffix
- Modal presentation enums use the `Sheet` suffix
- Repository protocols live in `Domain`; concrete implementations use the `Impl` suffix in `Data`
- Flow-local `Route` and `Sheet` types live with the router that owns them
- Each navigation flow is organized under `AppNavigation/Navigation/<Flow>/`

Examples:

- `AuthNavigationView`
- `CoffeeRouter`
- `LoginViewScreen`
- `RegisterStore`
- `ShopsRouter.Route`
- `MainRouter.Sheet`
- `AuthRepository` / `AuthRepositoryImpl`

## Repository Rules

The repository is guided by a few core rules:

- Observation is the state mechanism
- Environment is the shared context mechanism
- Store ownership is explicit and should live in the least common owner that needs that state
- Navigation containers own routers
- Stores own feature logic, but not navigation
- Views must not absorb business logic
- Shared behavior should be centralized once in the correct boundary
- Accessibility is part of the default implementation, not a follow-up task
