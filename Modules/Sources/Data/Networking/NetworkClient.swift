import Foundation
import OSLog

// HTTP/2 Multiplexing: https://developer.apple.com/videos/play/wwdc2024/10064/
// TLS 1.3 Adoption: https://support.apple.com/guide/security/tls-security-sec100a75d12/web
// Typed Throws: https://github.com/apple/swift-evolution/blob/main/proposals/0413-typed-throws.md
// Structured Logging: https://developer.apple.com/videos/play/wwdc2023/10226/

public final class NetworkClient: Sendable {

    private let baseURL: String
    private let session: URLSession
    private let interceptors: [RequestInterceptor]
    private let logger: Logger

    public init(
        baseURL: String,
        session: URLSession = .shared,
        interceptors: [RequestInterceptor],
        bundleIdentifier: String? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.interceptors = interceptors
        self.logger = Logger(
            subsystem: bundleIdentifier ?? "modules",
            category: "NetworkClient"
        )
    }
    
    func request(_ endpoint: APIEndpoint) async throws(APIError) -> APIResponse {
        let urlRequest = try endpoint.makeURLRequest(baseURL: baseURL)
        logger.debug("\(endpoint.method.rawValue) \(endpoint.path)")
        do {
            // https://developer.apple.com/videos/play/wwdc2023/10170 => When building async middleware chains, construct them in reverse order so the first middleware wraps the entire chain.
            var next: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, session in
                let (data, urlResponse) = try await session.data(for: request)
                guard let http = urlResponse as? HTTPURLResponse else {
                    throw APIError.unknownError(URLError(.badServerResponse))
                }
                return .init(request: request, response: http, data: data)
            }

            for interceptor in interceptors.reversed() {
                let current = next
                next = { @Sendable request, session in
                    try await interceptor.intercept(request: request, session: session, next: current)
                }
            }
            
            let response = try await next(urlRequest, session).validate()
            logger.info("\(endpoint.path) → \(response.statusCode)")
            return response

        } catch let error as APIError {
            logger.error("\(endpoint.path) - \(String(describing: error))")
            throw error
        } catch {
            logger.error("\(endpoint.path) - Unexpected: \(error)")
            throw APIError.unknownError(error)
        }

    }
}

extension URLSession {
    static func apiDefault() -> URLSession {
        let config = URLSessionConfiguration.default

        // Connection Management
        // Source: https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1407597-httpmaximumconnectionsperhost
        config.httpMaximumConnectionsPerHost = 6

        // Timeouts
        // Source: https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1408259-timeoutintervalforrequest
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        // Cache Policy
        // Source: https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1411655-requestcachepolicy
        config.requestCachePolicy = .useProtocolCachePolicy

        // TLS 1.3 (33% faster handshake than TLS 1.2)
        // Source: https://support.apple.com/guide/security/tls-security-sec100a75d12/web
        config.tlsMinimumSupportedProtocolVersion = .TLSv13

        // Wait for connectivity instead of failing immediately
        // Source: https://developer.apple.com/documentation/foundation/urlsessionconfiguration/2908812-waitsforconnectivity
        config.waitsForConnectivity = true
        
        // https://developer.apple.com/documentation/foundation/httpcookiestorage/cookieacceptpolicy => by default is true
        config.httpCookieAcceptPolicy = .never
        config.httpShouldSetCookies = false
        
        // https://developer.apple.com/documentation/foundation/urlcache
        config.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,   // 20MB en RAM
            diskCapacity: 100 * 1024 * 1024,    // 100MB en disco
            diskPath: "com.miapp.networkcache"
        )

        return URLSession(configuration: config)
    }
}
