import Foundation

public struct NetworkClientConfiguration: Sendable {
    public let baseURL: URL
    public let subsystem: String
    public let keychainService: String

    public init(
        baseURL: URL,
        subsystem: String,
        keychainService: String
    ) {
        self.baseURL = baseURL
        self.subsystem = subsystem
        self.keychainService = keychainService
    }

    public static func live(bundleIdentifier: String?) -> NetworkClientConfiguration {
        let resolvedIdentifier = bundleIdentifier
            ?? Bundle.main.bundleIdentifier
            ?? ProcessInfo.processInfo.processName

        return NetworkClientConfiguration(
            baseURL: Environment.current.baseURL,
            subsystem: resolvedIdentifier,
            keychainService: resolvedIdentifier
        )
    }
}
