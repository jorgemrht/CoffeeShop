import Foundation

public struct RetryInterceptor: RequestInterceptor {
    private let maxAttempts: Int
    private let baseDelay: TimeInterval
    private let maxDelay: TimeInterval
    private let retryableStatusCodes: Set<Int>
    private let transientURLErrors: Set<URLError.Code>

    public init(
        maxAttempts: Int = 3,
        baseDelay: TimeInterval = 0.5,
        maxDelay: TimeInterval = 30.0,
        retryableStatusCodes: Set<Int> = [408, 429, 500, 502, 503, 504],
        transientURLErrors: Set<URLError.Code> = [
            .timedOut,
            .cannotFindHost,
            .cannotConnectToHost,
            .networkConnectionLost,
            .notConnectedToInternet,
            .dnsLookupFailed
        ]
    ) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
        self.retryableStatusCodes = retryableStatusCodes
        self.transientURLErrors = transientURLErrors
    }

    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping @Sendable (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {
        guard request.isRetryAllowed else {
            return try await next(request, session)
        }

        for attempt in 0..<maxAttempts {
            do {
                let response = try await next(request, session)
                guard retryableStatusCodes.contains(response.statusCode) else {
                    return response
                }

                guard attempt < maxAttempts - 1 else {
                    return response
                }

                try await sleepWithRetryAfter(response: response, attempt: attempt)

            } catch let apiError as APIError {
                guard case .serverError(let response) = apiError,
                      retryableStatusCodes.contains(response.statusCode) else {
                    throw apiError
                }

                guard attempt < maxAttempts - 1 else {
                    throw apiError
                }

                try await sleepWithRetryAfter(response: response, attempt: attempt)

            } catch let urlError as URLError {
                if urlError.code == .timedOut {
                    guard attempt < maxAttempts - 1 else {
                        throw APIError.timeout
                    }
                    try await sleepWithExponentialBackoff(attempt: attempt)

                } else if transientURLErrors.contains(urlError.code) {
                    guard attempt < maxAttempts - 1 else {
                        throw urlError
                    }
                    try await sleepWithExponentialBackoff(attempt: attempt)

                } else {
                    throw urlError
                }

            } catch {
                throw APIError.unknownError(error)
            }
        }

        throw APIError.unknownError(nil)
    }
}

private extension RetryInterceptor {
    func sleepWithRetryAfter(response: APIResponse, attempt: Int) async throws {
        if let retryAfterValue = response.response.value(forHTTPHeaderField: "Retry-After") {
            if let seconds = TimeInterval(retryAfterValue) {
                try await sleep(seconds: min(seconds, maxDelay))
                return
            } else if let httpDate = parseHTTPDate(retryAfterValue) {
                let waitTime = max(0, httpDate.timeIntervalSinceNow)
                try await sleep(seconds: min(waitTime, maxDelay))
                return
            }
        }

        try await sleepWithExponentialBackoff(attempt: attempt)
    }

    func sleepWithExponentialBackoff(attempt: Int) async throws {
        let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
        let cappedDelay = min(exponentialDelay, maxDelay)
        try await sleep(seconds: Double.random(in: 0...cappedDelay))
    }

    func sleep(seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }

    func parseHTTPDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")

        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        if let date = formatter.date(from: dateString) {
            return date
        }

        formatter.dateFormat = "EEEE, dd-MMM-yy HH:mm:ss z"
        if let date = formatter.date(from: dateString) {
            return date
        }

        formatter.dateFormat = "EEE MMM d HH:mm:ss yyyy"
        return formatter.date(from: dateString)
    }
}

private extension URLRequest {
    var isRetryAllowed: Bool {
        if value(forHTTPHeaderField: "X-Allow-Retry") == "1" {
            return true
        }

        switch httpMethod?.uppercased() {
        case "GET", "HEAD", "PUT", "DELETE", "OPTIONS", "TRACE":
            return true
        default:
            return false
        }
    }
}
