# CoffeeShop

## Project structure

### Network Architecture

```
Data/
  │
  ├── DataSources/              # Definition of endpoints
  │   ├── APIEndpoint.swift     # Type-safe abstraction
  │   └── Endpoints/            # Endpoint Factories
  │       ├── LoginEndpoints
  │       ├── ShopEndpoints
  │       └── DiagnosticsEndpoints
  │
  ├── Extension/                
  │   ├── JSONEncoder+Ext       # snake_case encoding
  │   └── JSONDecoder+Ext       # snake_case decoding
  │
  ├── Models/                   #  DTOs
  │   ├── Core/                 #  Core models for Networking
  │   │   ├── Token
  │   │   ├── ServerErrorDTO
  │   │   ├── DeviceInfo
  │   │   ├── HTTPMethod
  │   │   └── LogsRequestDTO
  │   ├── Request/              # DTOs request
  │   │   ├── LoginRequestDTO
  │   │   └── RegisterRequestDTO
  │   └── Response/             # DTOs response
  │       ├── LoginResponseDTO
  │       └── CoffeShopsResponseDTO
  │
  ├── Networking/               
  │   ├── NetworkClient         # Main URLSession
  │   ├── APIResponse           # Wrapper response
  │   ├── APIError              # Errors networking
  │   ├── Environment           # URLs staging/prod
  │   ├── RequestInterceptor    # Protocol
  │   ├── LoggingConfiguration  # Config logging
  │   └── Interceptor/          # Middleware
  │       ├── RetryInterceptor
  │       ├── BearerAuthInterceptor
  │       ├── RefreshTokenInterceptor
  │       └── LoggingInterceptor
  │
  └── Repositories/             # Implementions
      ├── AuthRepositoryImpl
      └── DiagnosticsRepositoryImpl
```

#### What is Data and what is its function?

Data is the **infrastructure layer** that handles all communication with external services (REST APIs, databases, etc.). Its main function is:

**Data Responsibilities**

1. Implement Domain protocols
   - **Domain** defines AuthRepository (protocol)
   - **Data** implements AuthRepositoryImpl (concrete implementation)
2. Handle HTTP communication
   - Construct requests
   - Execute requests
   - Parse responses
   - Handle network errors
3. Transform data between layers
   - Server sends JSON in snake_case
   - **Data** converts it to a DTO
   - DTO maps to **Domain**: UserSession
4. Manage cross-cutting concerns
   - Automatic retry on failures
   - Token refresh
   - Logging requests/responses
   - Bearer authentication

**What Data DOESN'T do**
  - Doesn't contain business logic (that's Domain)
  - Doesn't interact with the UI (that's SharedCore/Features)
  - Doesn't depend on upper layers
  - Doesn't know about SwiftUI/UIKit

### Complete Flow of a Request

**Complete Flow of a Request:** UI Layer (FeatureLogin)

```
struct LoginView: View {
    @Environment(LoginStore.self) private var store

    var body: some View {
      Button("Login") {
      Task {
        await store.login(email: "user@example.com", password: "pass")
      }
    }
  }
}
```

**Business Logic Layer:** (SharedCore)

```
// LoginStore.swift (en SharedCore)
@MainActor
@Observable
public final class LoginStore {
  private let authRepo: AuthRepository  // ← Protocol de Domain

  public func login(email: String, password: String) async {
    do {
      // call the repository, implement in data
      let userSession = try await authRepo.login(email: email, password: password)
      self.isLoggedIn = true
    } catch let appError as AppError {
      self.errorMessage = appError.localizedDescription
    }
  }
}
```

**Domain Layer (Protocolos):**

```
// AuthRepository.swift (in Domain)
public protocol AuthRepository: Sendable {
  func login(email: String, password: String) async throws -> UserSession
}

// UserSession.swift (in Domain)
public struct UserSession {
  public let token: String
}

// AppError.swift (in Domain)
public enum AppError: Error {
  case unauthorized
  case networkError
  case serverError(ServerError?)
}
```

**Data Layer:** - Implement in the Repositorio

```
  // AuthRepositoryImpl.swift (in Data)
public struct AuthRepositoryImpl: AuthRepository, Sendable {
    private let networkClient: NetworkClient

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func login(email: String, password: String) async throws -> UserSession {
        do {
            // 1. Create endpoint
            let endpoint = LoginEndpoints.login(email: email, password: password).endpoint

            // 2. Request througt NetworkClient
            let response = try await networkClient.request(endpoint)

            // 3. Decode DTO
            let dto = try response.decoded(LoginResponseDTO.self)

            // 4. Mapp to Domain
            return dto.toDomain()

        } catch let apiError as APIError {
          // Mapp error to Damain
            throw apiError.toDomain()
        } catch {
            throw AppError.internalError(error)
        }
    }
}
```
