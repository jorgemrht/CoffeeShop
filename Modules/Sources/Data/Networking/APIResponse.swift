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
        try? JSONDecoder.decoderDefault().decode(ServerErrorDTO.self, from: data)
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
        using decoder: JSONDecoder = .decoderDefault()
    ) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
