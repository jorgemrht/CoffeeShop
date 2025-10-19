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

    public func serverError(using decoder: JSONDecoder = JSONDecoder()) -> ServerErrorDTO? {
        try? decoder.decode(ServerErrorDTO.self, from: data)
    }

    @discardableResult
    public func validate(using decoder: JSONDecoder = JSONDecoder()) throws -> Self {
        guard (200..<300).contains(statusCode) else {
            throw APIError.serverError(
                status: statusCode,
                data: data,
                server: serverError(using: decoder)
            )
        }
        return self
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

public extension APIResponse {
    func decoded<T: Decodable>(
        _ type: T.Type = T.self,
        using decoder: JSONDecoder = .apiDefaultJSONDecoder()
    ) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch let e as DecodingError {
            throw APIError.decodingFailed(e)
        } catch {
            let ctx = DecodingError.Context(codingPath: [], debugDescription: error.localizedDescription)
            throw APIError.decodingFailed(.dataCorrupted(ctx))
        }
    }
}
