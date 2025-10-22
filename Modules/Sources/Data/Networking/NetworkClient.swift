import Foundation

final class NetworkClient: Sendable {
    
    private let baseURL: String
    private let session: URLSession
    private let interceptors: [RequestInterceptor]

    public init(baseURL: String, session: URLSession = .shared, interceptors: [RequestInterceptor]) {
        self.baseURL = baseURL
        self.session = session
        self.interceptors = interceptors
    }

    func request(_ endpoint: APIEndpoint) async throws(APIError) -> APIResponse {
        let urlRequest = try endpoint.makeURLRequest(baseURL: baseURL)
        do {
            var next: (URLRequest, URLSession) async throws -> APIResponse = { request, session in
                let (data, urlResponse) = try await session.data(for: request)
                guard let http = urlResponse as? HTTPURLResponse else {
                    throw APIError.unknownError(URLError(.badServerResponse))
                }
                return .init(request: request, response: http, data: data)
            }

            for interceptor in interceptors.reversed() {
                let current = next
                next = { request, session in
                    try await interceptor.intercept(request: request, session: session, next: current)
                }
            }
            
            return try await next(urlRequest, session).validate()
        } catch let error as APIError {
            // Loh
            throw error
        } catch {
            // Log
            throw APIError.unknownError(error)
        }

    }
}
