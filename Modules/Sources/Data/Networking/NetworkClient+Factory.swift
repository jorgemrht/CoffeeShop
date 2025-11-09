import Foundation

extension NetworkClient {

    public static func `default`(bundleIdentifier: String?) -> NetworkClient {
        NetworkClient(
            baseURL: Environment.current.baseURL.absoluteString,
            session: .apiDefault(),
            interceptors: createDefaultInterceptors(subsystem: bundleIdentifier),
            bundleIdentifier: bundleIdentifier
        )
    }

    private static func createDefaultInterceptors(subsystem: String?) -> [RequestInterceptor] {
        let loggingConfig = LoggingConfiguration.current
        let loggerInterceptor = loggingConfig.createInterceptor(
            subsystem: subsystem,
            category: "NetworkClient"
        )

        return [loggerInterceptor]
    }
}
