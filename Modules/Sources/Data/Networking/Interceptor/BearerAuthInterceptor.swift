import Foundation

public struct BearerAuthInterceptor: RequestInterceptor {
    
    private let tokenProvider: @Sendable () async -> Token?

    public init(tokenProvider: @escaping @Sendable () async -> Token?) {
        self.tokenProvider = tokenProvider
    }

    public func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse {
        if let token = await tokenProvider() {
            guard !token.isExpired else {
                throw APIError.unauthorized
            }
            var modifiedRequest = request
            modifiedRequest.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")
            return try await next(modifiedRequest, session)
        }
        return try await next(request, session)

    }
}
