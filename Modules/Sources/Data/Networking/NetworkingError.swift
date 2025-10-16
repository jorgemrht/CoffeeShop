import Foundation

public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)
    case decodingFailed(Error)
}
