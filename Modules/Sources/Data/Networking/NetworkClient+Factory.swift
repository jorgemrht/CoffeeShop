import Foundation

extension NetworkClient {

    public static func `default`() -> NetworkClient {
        let bundle = Bundle.main
        return `default`(bundleIdentifier: bundle.bundleIdentifier)
    }

    public static func `default`(bundleIdentifier: String?) -> NetworkClient {
        makeDefault(bundleIdentifier: bundleIdentifier)
    }

    public static func unauthenticatedDefault(bundleIdentifier: String?) -> NetworkClient {
        makeDefault(bundleIdentifier: bundleIdentifier)
    }

    private static func makeDefault(
        bundleIdentifier: String?
    ) -> NetworkClient {
        let configuration = NetworkClientConfiguration.live(bundleIdentifier: bundleIdentifier)
        let keychainDataSource = KeychainDataSourceImpl()
        let tokenStore = TokenStore(
            keychainDataSource: keychainDataSource,
            service: configuration.keychainService
        )

        return NetworkClient(
            baseURL: configuration.baseURL,
            session: .apiDefault(),
            interceptors: createDefaultInterceptors(
                subsystem: configuration.subsystem,
                tokenStore: tokenStore,
                keychainDataSource: keychainDataSource,
                keychainService: configuration.keychainService
            ),
            subsystem: configuration.subsystem,
            tokenStore: tokenStore
        )
    }

    private static func createDefaultInterceptors(
        subsystem: String,
        tokenStore: TokenStore,
        keychainDataSource: any KeychainDataSource,
        keychainService: String
    ) -> [RequestInterceptor] {
        let loggingConfig = LoggingConfiguration.current
        let loggerInterceptor = loggingConfig.createInterceptor(
            subsystem: subsystem,
            category: "NetworkClient"
        )

        var interceptors: [RequestInterceptor] = []

        interceptors.append(RetryInterceptor())
        interceptors.append(
            BearerAuthInterceptor(
                tokenProvider: {
                    try? await tokenStore.token()
                }
            )
        )
        interceptors.append(
            PayloadSecurityInterceptor(
                keychainDataSource: keychainDataSource,
                keychainService: keychainService
            )
        )
        interceptors.append(loggerInterceptor)

        return interceptors
    }
}
