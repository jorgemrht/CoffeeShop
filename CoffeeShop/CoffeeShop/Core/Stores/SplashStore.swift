import Foundation
import Observation

@MainActor
@Observable
public final class SplashStore {
    private let delay: Duration

    public init(delay: Duration = .seconds(2)) {
        self.delay = delay
    }

    public func nextDestination() async -> SplashDestination? {
        do {
            try await Task.sleep(for: delay)
        } catch {
            return nil
        }

        guard !Task.isCancelled else {
            return nil
        }

        return .auth
    }
}

public enum SplashDestination: Sendable {
    case auth
    case main
}
