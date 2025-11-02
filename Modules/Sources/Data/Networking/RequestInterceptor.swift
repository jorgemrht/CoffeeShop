import Foundation

public protocol RequestInterceptor: Sendable {
    func intercept(
        request: URLRequest,
        session: URLSession,
        next: @escaping @Sendable (URLRequest, URLSession) async throws -> APIResponse
    ) async throws -> APIResponse
}
