import Foundation

public struct APIEndpoint {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String:String]?
    public let queryItems: [URLQueryItem]?
    public let body: AnyEncodable?

    public init(path: String,
                method: HTTPMethod,
                headers: [String:String] = [:],
                queryItems: [URLQueryItem]? = nil,
                body: AnyEncodable? = nil) {
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
        components?.percentEncodedQueryItems = queryItems?.map { item in
            let disallowed = CharacterSet(charactersIn: "+&=?")
            let allowed = CharacterSet.urlQueryAllowed.subtracting(disallowed)

            let encodedName = item.name.addingPercentEncoding(withAllowedCharacters: allowed) ?? item.name
            let encodedValue = item.value?.addingPercentEncoding(withAllowedCharacters: allowed)

            return URLQueryItem(name: encodedName, value: encodedValue)
        }
        
        guard let url = components?.url else { throw APIError.unknownError(URLError(.badURL)) }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
            request.addValue(Bundle.main.preferredLocalizations.first ?? "es", forHTTPHeaderField: "Accept-Language")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingFailed(error)
            }
        }
        return request
    }
}
