import Foundation

public struct APIEndpoint {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String:String]?
    public let queryItems: [URLQueryItem]?
    public let body: (any Encodable)?

    public init(path: String,
                method: HTTPMethod,
                headers: [String:String] = [:],
                queryItems: [URLQueryItem]? = nil,
                body: (any Encodable)? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }
}

extension APIEndpoint {
    func makeURLRequest(baseURL: String) throws(APIError) -> URLRequest {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.unknownError(URLError(.badURL)) }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        if let lang = Locale.preferredLanguages.first {
            request.addValue(lang, forHTTPHeaderField: "Accept-Language")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder.encoderDefault().encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIError.encodingFailed(error)
            }
        }
        return request
    }
}
