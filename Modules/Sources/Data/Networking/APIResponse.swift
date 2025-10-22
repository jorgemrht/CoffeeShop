import Foundation

public struct APIResponse: Sendable {

    public let request: URLRequest
    public let response: HTTPURLResponse
    public let data: Data

    public init(request: URLRequest, response: HTTPURLResponse, data: Data) {
        self.request = request
        self.response = response
        self.data = data
    }

    public var statusCode: Int { response.statusCode }
    
    var serverError: ServerErrorDTO? {
        try? JSONDecoder().decode(ServerErrorDTO.self, from: data)
    }

    @discardableResult
    public func validate() throws -> Self {
        guard (200..<300).contains(statusCode) else {
            throw APIError.serverError(self)
        }
        
        return self
    }
}

public extension APIResponse {
    func decoded<T: Decodable>(
        _ type: T.Type = T.self,
        using decoder: JSONDecoder = .apiDefault()
    ) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}

extension APIResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        var msg = "### REQUEST ###\n"
        
        msg += "\(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "<nil>")\n"
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            msg += "Headers: \(headers)\n"
        }
        if let body = request.httpBody, !body.isEmpty,
           let s = String(data: body, encoding: .utf8) {
            msg += "Body: \(s)\n"
        }

        msg += "\n### RESPONSE (\(statusCode)) ###\n"
        if let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
           let txt = String(data: pretty, encoding: .utf8) {
            msg += txt
        } else if let txt = String(data: data, encoding: .utf8) {
            msg += txt
        } else {
            msg += "<\(data.count) bytes>"
        }
        return msg
    }
}
