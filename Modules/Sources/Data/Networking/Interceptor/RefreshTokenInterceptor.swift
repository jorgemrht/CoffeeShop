import Foundation

/// Interceptor that automatically handles the token refresh when it receives 401
/// Coordinate multiple concurrent requests to avoid duplicate refreshments
///
/// Source: WWDC 2021 - Protect mutable state with Swift actors (timestamp 15:42)
/// https://developer.apple.com/videos/play/wwdc2021/10133/
public final actor RefreshTokenInterceptor: RequestInterceptor {

    private let refresh: @Sendable () async throws -> String

    private var ongoingRefresh: Task<String, Error>?

    public init(refresh: @escaping @Sendable () async throws -> String) {
        self.refresh = refresh
    }

    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {

        if request.value(forHTTPHeaderField: "X-Bypass-Refresh") == "1" {
            return try await next(request, session)
        }

        do {
            return try await next(request, session)
        } catch let apiError as APIError {

            guard case .serverError(let resp) = apiError, resp.statusCode == 401 else {
                throw apiError
            }


            let newToken: String
            do {
                newToken = try await coordinatedRefresh()
            } catch {
                throw APIError.unauthorized
            }

            var retried = request
            retried.setValue("1", forHTTPHeaderField: "X-Bypass-Refresh")
            retried.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")

            do {
                return try await next(retried, session)
            } catch let retryError as APIError {
                if case .serverError(let retryResp) = retryError, retryResp.statusCode == 401 {
                    throw APIError.unauthorized
                }
                throw retryError
            }
        }
    }
    
    private func coordinatedRefresh() async throws -> String {
        if let existingRefresh = ongoingRefresh {
            return try await existingRefresh.value
        }

        let refreshTask = Task<String, Error> {
            do {
                let token = try await refresh()
                return token
            } catch {
                throw error
            }
        }

        ongoingRefresh = refreshTask

        do {
            let token = try await refreshTask.value
            ongoingRefresh = nil
            return token
        } catch {
            ongoingRefresh = nil
            throw error
        }
    }
}
