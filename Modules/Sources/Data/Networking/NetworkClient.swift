import Foundation
import Domain
import OSLog

public final class NetworkClient: Sendable {

    private let baseURL: URL
    private let session: URLSession
    private let interceptors: [RequestInterceptor]
    private let logger: Logger
    private let tokenStore: TokenStore?

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        interceptors: [RequestInterceptor],
        subsystem: String
    ) {
        self.baseURL = baseURL
        self.session = session
        self.interceptors = interceptors
        self.logger = Logger(
            subsystem: subsystem,
            category: "NetworkClient"
        )
        self.tokenStore = nil
    }

    init(
        baseURL: URL,
        session: URLSession = .shared,
        interceptors: [RequestInterceptor],
        subsystem: String,
        tokenStore: TokenStore
    ) {
        self.baseURL = baseURL
        self.session = session
        self.interceptors = interceptors
        self.logger = Logger(
            subsystem: subsystem,
            category: "NetworkClient"
        )
        self.tokenStore = tokenStore
    }
    
    public func request(_ endpoint: APIEndpoint) async throws(APIError) -> APIResponse {
        let urlRequest = try endpoint.makeURLRequest(baseURL: baseURL)
        logger.debug("\(endpoint.method.rawValue) \(endpoint.path)")
        do {
            // https://developer.apple.com/videos/play/wwdc2023/10170 => When building async middleware chains, construct them in reverse order so the first middleware wraps the entire chain.
            var next: @Sendable (URLRequest, URLSession) async throws -> APIResponse = { request, session in
                let (data, urlResponse) = try await session.data(for: request)
                guard let http = urlResponse as? HTTPURLResponse else {
                    throw APIError.unknownError(URLError(.badServerResponse))
                }
                return APIResponse(request: request, response: http, data: data)
            }

            for interceptor in interceptors.reversed() {
                let current = next
                next = { @Sendable request, session in
                    try await interceptor.intercept(request: request, session: session, next: current)
                }
            }
            
            let response = try await next(urlRequest, session)
            let validatedResponse = try response.validate()
            logger.info("\(endpoint.path) → \(validatedResponse.statusCode)")
            return validatedResponse

        } catch let error as APIError {
            logger.error("\(endpoint.path) - \(String(describing: error))")
            throw error
        } catch {
            logger.error("\(endpoint.path) - Unexpected: \(error)")
            throw APIError.unknownError(error)
        }

    }

    func saveSession(_ session: UserSession) async throws {
        try await tokenStore?.save(Token(session: session))
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
