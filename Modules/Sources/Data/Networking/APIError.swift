import Foundation

public enum APIError: Error, Sendable {
    case invalidURL
    case serverError(status: Int, data: Data, server: ServerErrorDTO?)
    case unknownError
    case decodingFailed(DecodingError)
    case encodingFailed(EncodingError)
}
