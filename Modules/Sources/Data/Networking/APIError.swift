import Foundation
import Domain

public enum APIError: Error {
    case unauthorized
    case networkError
    case timeout
    case invalidURL(url: String)
    case encodingFailed(Error)
    case decodingFailed(Error)
    case serverError(APIResponse)
    case unknownError(Error?)
}

public extension APIError {
    func toDomain() -> AppError {
        switch self {
        case .unauthorized:
            AppError.unauthorized
        case .invalidURL(let url):
            AppError.serverError(
                .init(
                    identifier: nil,
                    statusCode: nil,
                    message: "Invalid URL: \(url)")
            )
        case .serverError(let serverError):
            AppError.serverError(
                .init(
                    identifier: serverError.serverError?.identifier,
                    statusCode: serverError.statusCode,
                    message: serverError.serverError?.message
                )
            )
        case .encodingFailed(let error), .decodingFailed(let error):
            AppError.internalError(error)
        case .unknownError(let error):
            AppError.internalError(error)
        case .timeout:
            AppError.timeout
        case .networkError:
            AppError.networkError
        }
    }
}
