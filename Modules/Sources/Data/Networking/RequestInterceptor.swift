import Foundation

public protocol RequestInterceptor: Sendable {
    func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse
}

public struct BearerAuthInterceptor: RequestInterceptor {
    private let tokenProvider: @Sendable () async -> String?

    public init(tokenProvider: @escaping @Sendable () async -> String?) {
        self.tokenProvider = tokenProvider
    }

    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {
        var req = request
        if req.value(forHTTPHeaderField: "Authorization") == nil, let token = await tokenProvider() {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Header API oficial. :contentReference[oaicite:1]{index=1}
        }
        return try await next(req, session)
    }
}

public struct RefreshTokenInterceptor: RequestInterceptor {
    private let refresh: @Sendable () async throws -> String // devuelve nuevo access token

    public init(refresh: @escaping @Sendable () async throws -> String) {
        self.refresh = refresh
    }

    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {
        // Evita bucle marcando el reintento
        if request.value(forHTTPHeaderField: "X-Bypass-Refresh") == "1" {
            return try await next(request, session)
        }
        do {
            return try await next(request, session)
        } catch let apiError as APIError {
            if case .serverError(let resp) = apiError, resp.statusCode == 401 {
                // Coordinas refresh con tu AuthManager (actor) externamente. :contentReference[oaicite:2]{index=2}
                let newToken = try await refresh()
                var retried = request
                retried.setValue("1", forHTTPHeaderField: "X-Bypass-Refresh")
                retried.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                return try await next(retried, session)
            }
            throw apiError
        }
    }
}

public struct RetryInterceptor: RequestInterceptor {
    private let maxAttempts: Int
    private let baseDelay: TimeInterval
    private let transientCodes: Set<URLError.Code> = [.timedOut, .cannotFindHost, .cannotConnectToHost, .networkConnectionLost, .notConnectedToInternet, .dnsLookupFailed]

    public init(maxAttempts: Int = 3, baseDelay: TimeInterval = 0.5) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
    }

    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {
        var attempt = 0
        while true {
            do {
                return try await next(request, session)
            } catch let apiError as APIError {
                if case .serverError(let resp) = apiError,
                   (500...599).contains(resp.statusCode),
                   attempt < maxAttempts {
                    attempt += 1
                    let delay = baseDelay * pow(2, Double(attempt - 1))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                throw apiError
            } catch let urlError as URLError {
                if transientCodes.contains(urlError.code), attempt < maxAttempts {
                    attempt += 1
                    let delay = baseDelay * pow(2, Double(attempt - 1))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                throw urlError
            }
        }
    }
}

public struct MetricsLoggingInterceptor: RequestInterceptor {
    public init() {}
    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {
        let start = ContinuousClock.now
        // LOG: ➡️ \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")
        do {
            let resp = try await next(request, session)
            let dur = start.duration(to: .now)
            // LOG: ⬅️ \(resp.statusCode) [\(dur.components.seconds)s]
            // MÉTRICAS: status, duración, tamaño = resp.data.count
            return resp
        } catch {
            let dur = start.duration(to: .now)
            // LOG: ❌ \(error) [\(dur.components.seconds)s]
            // MÉTRICAS: fallo
            throw error
        }
    }
}
