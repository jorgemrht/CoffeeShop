import Observation

@MainActor
public enum LoadingBehavior {
    case skipIfAlreadyLoading
    case alwaysRun
}

@MainActor
public protocol StoreProtocol: AnyObject, Observable {
    var isLoading: Bool { get set }
    init(environment: AppDependencies)
}

@MainActor
public extension StoreProtocol {
    func withLoading(
        behavior: LoadingBehavior = .skipIfAlreadyLoading,
        _ operation: () async throws -> Void
    ) async rethrows {
        guard behavior == .alwaysRun || !isLoading else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        try await operation()
    }

    func withLoading<Value>(
        behavior: LoadingBehavior = .skipIfAlreadyLoading,
        _ operation: () async throws -> Value
    ) async rethrows -> Value? {
        guard behavior == .alwaysRun || !isLoading else {
            return nil
        }

        isLoading = true
        defer { isLoading = false }

        return try await operation()
    }
}
