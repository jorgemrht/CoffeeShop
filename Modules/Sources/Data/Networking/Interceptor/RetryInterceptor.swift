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

      // MARK: - RequestInterceptor

      public func intercept(
          request: URLRequest,
          session: URLSession,
          next: @escaping (URLRequest, URLSession) async throws -> APIResponse
      ) async throws -> APIResponse {

          for attempt in 0..<maxAttempts {
              do {
                  return try await next(request, session)

              } catch let apiError as APIError {
                  guard case .serverError(let response) = apiError,
                        retryableStatusCodes.contains(response.statusCode) else {
                      throw apiError
                  }

                  guard attempt < maxAttempts - 1 else {
                      throw apiError
                  }

                  // Respeta Retry-After header si está presente (RFC 9110)
                  try await sleepWithRetryAfter(response: response, attempt: attempt)

              } catch let urlError as URLError {
                  if urlError.code == .timedOut {
                      guard attempt < maxAttempts - 1 else {
                          throw APIError.timeout
                      }
                      // Para errores de timeout, usar exponential backoff
                      try await sleepWithExponentialBackoff(attempt: attempt)

                  } else if transientURLErrors.contains(urlError.code) {
                      guard attempt < maxAttempts - 1 else {
                          throw urlError
                      }

                      // Para errores transitorios, usar exponential backoff
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

      /// Wait before retrying, respecting Retry-After header if present
      /// - Parameters:
      ///   - response: The server response (may contain Retry-After header)
      ///   - attempt: Current attempt number (used for exponential backoff)
      private func sleepWithRetryAfter(response: APIResponse, attempt: Int) async throws {
          // 1. try extracting Retry-After header (RFC 9110 Section 10.2.3)
          // Source: https://www.rfc-editor.org/rfc/rfc9110.html#name-retry-after
          if let retryAfterValue = response.response.value(forHTTPHeaderField: "Retry-After") {
              // Retry-After it can be seconds (int) or an HTTP date
              if let seconds = TimeInterval(retryAfterValue) {
                  // Format: "Retry-After: 120" (120 segundos)
                  let cappedSeconds = min(seconds, maxDelay)
                  let nanoseconds = UInt64(cappedSeconds * 1_000_000_000)
                  try await Task.sleep(nanoseconds: nanoseconds)
                  return
              } else if let httpDate = parseHTTPDate(retryAfterValue) {
                  // Format: "Retry-After: Wed, 21 Oct 2025 07:28:00 GMT"
                  let now = Date()
                  let waitTime = max(0, httpDate.timeIntervalSince(now))
                  let cappedWaitTime = min(waitTime, maxDelay)
                  let nanoseconds = UInt64(cappedWaitTime * 1_000_000_000)
                  try await Task.sleep(nanoseconds: nanoseconds)
                  return
              }
          }

          // 2. If there is no Retry-After, use exponential backoff with jitter
          let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
          let cappedDelay = min(exponentialDelay, maxDelay)
          let jitteredDelay = Double.random(in: 0...cappedDelay)
          let nanoseconds = UInt64(jitteredDelay * 1_000_000_000)
          try await Task.sleep(nanoseconds: nanoseconds)
      }

      /// Wait using exponential backoff with jitter (for errors without Retry-After)
      private func sleepWithExponentialBackoff(attempt: Int) async throws {
          let exponentialDelay = baseDelay * pow(2.0, Double(attempt))
          let cappedDelay = min(exponentialDelay, maxDelay)
          let jitteredDelay = Double.random(in: 0...cappedDelay)
          let nanoseconds = UInt64(jitteredDelay * 1_000_000_000)
          try await Task.sleep(nanoseconds: nanoseconds)
      }

      /// Parse HTTP date format (RFC 9110 Section 5.6.7)
      /// Source: https://www.rfc-editor.org/rfc/rfc9110.html#name-date-time-formats
      private func parseHTTPDate(_ dateString: String) -> Date? {
          let formatter = DateFormatter()
          formatter.locale = Locale(identifier: "en_US_POSIX")
          formatter.timeZone = TimeZone(abbreviation: "GMT")

          // Format IMF-fixdate: "Sun, 06 Nov 1994 08:49:37 GMT"
          formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
          if let date = formatter.date(from: dateString) {
              return date
          }

          // Format obsoleto RFC 850: "Sunday, 06-Nov-94 08:49:37 GMT"
          formatter.dateFormat = "EEEE, dd-MMM-yy HH:mm:ss z"
          if let date = formatter.date(from: dateString) {
              return date
          }

          // Format obsoleto asctime: "Sun Nov  6 08:49:37 1994"
          formatter.dateFormat = "EEE MMM d HH:mm:ss yyyy"
          return formatter.date(from: dateString)
      }
  }

