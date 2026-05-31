import Foundation

extension NetworkClient {

    public static func `default`() -> NetworkClient {
        let bundle = Bundle.main
        return `default`(bundleIdentifier: bundle.bundleIdentifier)
    }

    public static func `default`(bundleIdentifier: String?) -> NetworkClient {
        let service = bundleIdentifier ?? "CoffeeShop"
        let refreshClient = unauthenticatedDefault(bundleIdentifier: bundleIdentifier)
        let authManager = AuthManager.live(
            service: service,
            refreshProvider: { refreshToken in
                let response = try await refreshClient.request(
                    LoginEndpoints.refresh(token: refreshToken).endpoint
                )
                let session = try response.decoded(LoginResponseDTO.self).toDomain()
                return Token(session: session)
            }
        )

        return `default`(
            authManager: authManager,
            bundleIdentifier: bundleIdentifier
        )
    }

    public static func unauthenticatedDefault(bundleIdentifier: String?) -> NetworkClient {
        makeDefault(
            authManager: nil,
            bundleIdentifier: bundleIdentifier
        )
    }

    public static func `default`(
        authManager: AuthManager,
        bundleIdentifier: String?
    ) -> NetworkClient {
        makeDefault(
            authManager: authManager,
            bundleIdentifier: bundleIdentifier
        )
    }

    private static func makeDefault(
        authManager: AuthManager?,
        bundleIdentifier: String?
    ) -> NetworkClient {
        NetworkClient(
            baseURL: Environment.current.baseURL.absoluteString,
            session: .apiDefault(),
            interceptors: createDefaultInterceptors(
                authManager: authManager,
                subsystem: bundleIdentifier
            ),
            authManager: authManager,
            bundleIdentifier: bundleIdentifier
        )
    }

    private static func createDefaultInterceptors(
        authManager: AuthManager?,
        subsystem: String?
    ) -> [RequestInterceptor] {
        let loggingConfig = LoggingConfiguration.current
        let loggerInterceptor = loggingConfig.createInterceptor(
            subsystem: subsystem,
            category: "NetworkClient"
        )

        var interceptors: [RequestInterceptor] = []

        if let authManager {
            interceptors.append(
                RefreshTokenInterceptor(refresh: {
                    try await authManager.refreshToken()
                })
            )
            interceptors.append(
                BearerAuthInterceptor(tokenProvider: {
                    await authManager.currentToken()
                })
            )
        }

        interceptors.append(RetryInterceptor())
        interceptors.append(loggerInterceptor)

        return interceptors
    }
}
