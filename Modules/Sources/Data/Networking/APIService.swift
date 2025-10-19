import Foundation

public actor APIService {

    private let baseURL: URL
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let defaultHeaders: [String:String] = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]

    public init(
        baseURL: URL = Environment.current.baseURL,
        session: URLSession = .apiDefault(),
        encoder: JSONEncoder = .apiDefaultJSONEncoder(),
        decoder: JSONDecoder = .apiDefaultJSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    @discardableResult
    private func request(
        _ endpoint: APIEndpoint,
        body: Data?,
        _ token: String?,
        _ extraHeaders: [String:String]
    ) async throws -> APIResponse {

        guard var comps = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        
        comps.path = comps.path.appending(endpoint.path)
        if !endpoint.queryItems.isEmpty { comps.queryItems = endpoint.queryItems }
        guard let url = comps.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        var headers = defaultHeaders.merging(endpoint.headers) { _, rhs in rhs }
        if let token { headers["Authorization"] = "Bearer \(token)" }
        if !extraHeaders.isEmpty { headers.merge(extraHeaders) { _, rhs in rhs } }

        request.allHTTPHeaderFields = headers
        request.httpBody = body

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidURL }

        guard (200..<300).contains(http.statusCode) else {
            let server = try? decoder.decode(ServerErrorDTO.self, from: data)
            throw APIError.serverError(status: http.statusCode, data: data, server: server)
        }

        return try APIResponse(request: request, response: http, data: data).validate()
    }
}

public extension URLSession {
    static func apiDefault() -> URLSession {
        URLSession(configuration: .apiDefault())
    }
}

public extension APIService {
    @discardableResult
    func get(
        _ endpoint: APIEndpoint,
        token: String = "",
        headers: [String:String] = [:]
    ) async throws -> APIResponse {
        try await request(endpoint, body: nil, token, headers)
    }

    func delete(
        _ endpoint: APIEndpoint,
        token: String = "",
        headers: [String:String] = [:]
    ) async throws -> APIResponse {
        try await request(endpoint, body: nil, token, headers)
    }

    func post<B: Encodable>(
        _ endpoint: APIEndpoint,
        body: B,
        token: String = "",
        headers: [String:String] = [:]
    ) async throws -> APIResponse {
        let data = try encodeBody(body)
        return try await request(endpoint, body: data, token, headers)
    }

    func put<B: Encodable>(
        _ endpoint: APIEndpoint,
        body: B,
        token: String = "",
        headers: [String:String] = [:]
    ) async throws -> APIResponse {
        let data = try encodeBody(body)
        return try await request(endpoint, body: data, token, headers)
    }
}

private extension APIService {
    func encodeBody<B: Encodable>(_ body: B) throws -> Data {
        do {
            return try encoder.encode(body)
        } catch let e as EncodingError {
            throw APIError.encodingFailed(e)
        } catch {
            let ctx = EncodingError.Context(codingPath: [], debugDescription: error.localizedDescription)
            throw APIError.encodingFailed(.invalidValue(body, ctx))
        }
    }
}

private extension URLSessionConfiguration {
    static func apiDefault() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.requestCachePolicy = .useProtocolCachePolicy
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return config
    }
}
